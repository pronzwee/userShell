pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
   id: root

   property var players: Mpris.players.values
   readonly property var player: players.length > 0 ? players[0] : null
   readonly property bool available: player !== null
   readonly property string trackTitle: player ? player.trackTitle : ""
   readonly property string trackArtist: player ? player.trackArtist : ""
   readonly property string trackArtUrl: player ? player.trackArtUrl : ""
   readonly property real position: player ? (player.position / 1000000) : 0
   readonly property int playbackState: player ? player.playbackState : MprisPlaybackState.Stopped
   readonly property bool isPlaying: playbackState === MprisPlaybackState.Playing
   readonly property bool isPaused: playbackState === MprisPlaybackState.Paused
   readonly property bool isStopped: playbackState === MprisPlaybackState.Stopped
   readonly property string trackAlbum: player ? player.trackAlbum : ""
   readonly property real length: player ? (player.length / 1000000) : 0
   readonly property real volume: player ? player.volume : 0
   readonly property bool canControl: player ? player.canControl : false
   readonly property bool canGoNext: player ? player.canGoNext : false
   readonly property bool canGoPrevious: player ? player.canGoPrevious : false
   readonly property bool canSeek: player ? player.canSeek : false
   readonly property string playerIdentity: player ? player.identity : ""
   readonly property string positionText: formatTime(position)
   readonly property string lengthText: formatTime(length)

   property string currentTrack: ""
   property string currentArtist: ""
   property var parsedLyrics: []

   readonly property int activeLyricIndex: {
      if (!parsedLyrics || parsedLyrics.length === 0) return 0;
      let currentPos = position;
      let idx = 0;
      for (let i = 0; i < parsedLyrics.length; i++) {
         if (parsedLyrics[i].time <= currentPos) {
            idx = i;
         } else {
            break;
         }
      }
      return idx;
   }

   Timer {
      running: player && player.playbackState == MprisPlaybackState.Playing
      interval: 500
      repeat: true
      onTriggered: player.positionChanged()
   }

   readonly property string currentLyric: (parsedLyrics.length > 0 && parsedLyrics[activeLyricIndex])
      ? parsedLyrics[activeLyricIndex].text
      : "Load Lyrics.."

   Connections {
      target: Mpris.players
      function onValuesChanged() {
         root.players = Mpris.players.values
      }
   }

   FrameAnimation {
      running: root.isPlaying
      onTriggered: if (root.player) root.player.positionChanged()
   }

   onTrackTitleChanged: {
      if (trackTitle && (trackTitle !== currentTrack || trackArtist !== currentArtist))
         fetchLyrics(trackTitle, trackArtist)
   }
   onTrackArtistChanged: {
      if (trackTitle && trackArtist !== currentArtist)
         fetchLyrics(trackTitle, trackArtist)
   }

   function togglePlayPause() {
      if (player && player.canTogglePlaying) player.togglePlaying()
   }
   function play() {
      if (player && player.canPlay) player.play()
   }
   function pause() {
      if (player && player.canPause) player.pause()
   }
   function stop() {
      if (player) player.stop()
   }
   function next() {
      if (player && player.canGoNext) player.next()
   }
   function previous() {
      if (player && player.canGoPrevious) player.previous()
   }
   function seek(seconds) {
      if (player && player.canSeek) player.position = seconds * 1000000
   }
   function setVolume(value) {
      if (player && player.volumeSupported) player.volume = Math.max(0, Math.min(1, value))
   }

   function formatTime(seconds) {
      if (isNaN(seconds) || seconds < 0) return "00:00"
      let m = Math.floor(seconds / 60)
      let s = Math.floor(seconds % 60)
      return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
   }

   function fetchLyrics(title, artist) {
      if (!title) return
      currentTrack = title
      currentArtist = artist
      parsedLyrics = []
      lyricProc.running = false
      lyricProc.buffer = ""
      let encodedTitle = encodeURIComponent(title)
      let encodedArtist = encodeURIComponent(artist)
      lyricProc.command = ["curl", "-s", "-m", "10",
         `https://lrclib.net/api/get?track_name=${encodedTitle}&artist_name=${encodedArtist}`]
      lyricProc.running = true
   }

   function parseSyncedLyrics(lrcString) {
      let lines = lrcString.split("\n");
      let result = [];
      let regex = /\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)/;

      for (let i = 0; i < lines.length; i++) {
         let match = regex.exec(lines[i]);
         if (match) {
            let minutes = parseInt(match[1], 10);
            let seconds = parseInt(match[2], 10);
            let milliseconds = parseInt(match[3], 10);
            let totalSeconds = (minutes * 60) + seconds + (milliseconds / (match[3].length === 3 ? 1000 : 100));
            let text = match[4].trim();
            if (text.length > 0) {
               result.push({ time: totalSeconds, text: text });
            }
         }
      }
      return result;
   }

   Process {
      id: lyricProc
      running: false
      property string buffer: ""

      stdout: SplitParser {
         splitMarker: ""
         onRead: data => lyricProc.buffer += data
      }

      onExited: (exitCode, exitStatus) => {
         let raw = lyricProc.buffer
         lyricProc.buffer = ""
         if (exitCode !== 0 || raw.length === 0) {
            root.parsedLyrics = [{ time: 0, text: "Failed parsing.." }]
            return
         }
         try {
            let json = JSON.parse(raw)
            if (json && json.syncedLyrics) {
               root.parsedLyrics = root.parseSyncedLyrics(json.syncedLyrics)
            } else if (json && json.plainLyrics) {
               root.parsedLyrics = [{ time: 0, text: json.plainLyrics }]
            } else {
               root.parsedLyrics = [{ time: 0, text: "Lyric not found" }]
            }
         } catch (e) {
            root.parsedLyrics = [{ time: 0, text: "Failed parsing.." }]
         }
      }
   }
}