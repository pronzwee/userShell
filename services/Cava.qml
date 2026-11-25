pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
   id: root

   property int bars: 10
   property var levels: Array(bars).fill(0)
   property int total: 0

   Process {
      id: proc
      running: true
      command: ["cava", "-p", Quickshell.shellDir + "/services/cava/cava.conf"]
      stdout: SplitParser {
         splitMarker: "\n"
         onRead: data => {
            const parts = data.split(";")
            if (parts.length > 1 && parts[parts.length - 1] === "") parts.pop()
            if (parts.length > 1 && parts.length !== root.bars) root.bars = parts.length
            const out = []
            var totalOut = 0
            for (let i = 0; i < root.bars; i++) {
               const v = parseInt(parts[i])
               const value = isNaN(v) ? 0 : Math.max(0, Math.min(1, v / 100))
               out.push(value)
               totalOut += value
            }
            root.levels = out
            root.total  = totalOut
         }
      }
      onRunningChanged: if (!running) root.levels = Array(root.bars).fill(0)
   }
}