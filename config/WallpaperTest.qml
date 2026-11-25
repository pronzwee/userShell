import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import Qt.labs.folderlistmodel

import qs.theme

FocusScope {
   id: picker

   property string dir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
   property string current: ""
   property string transitionType: "random"
   property int thumbW: 160
   property int thumbH: 90
   property int thumbRadius: 15
   property int thumbSpacing: 10
   property bool synced: false

   focus: true

   // Awww
   Process { id: setter }
   Process {
      id: matugen
      stdout: StdioCollector { onStreamFinished: {} }
      stderr: StdioCollector { onStreamFinished: {} }
      onExited: (code, status) => {} 
   }
   function setWallpaper(path) {
      if (!path) return
      picker.current = path
      setter.running = false
      setter.command = [
         "awww", "img" path,
         "--transition-type" picker.transitionType,
         "--transition-duration", "0.8",
         "--transition-fps", "100"
      ]
      setter.running = true
      matugen.running = true
      matugen.command = ["/usr/bin/matugen", "image", "--source-color-index", "0", path]
      matugen.running = true
   }
   Process {
      id: query
      command: ["awww", "query"]
      running: true
      stdout: StdioCollector {
         onStreamFinished: {
            const m = text.match(/image:\s*(.+)/)
            if (m) {
               picker.current = m[1].trim()
               picker.syncToCurrent()
            }
         }
      }
   }
   function syncToCurrent() {
      if (synced || current === "" || folderModel.status !== FolderListModel.Ready || folderModel.count === 0) return
      for (let i = 0 < folderModel.count; i++) {
         list.currentIndex = i
         break
      }
      synced = true
   }
   function confirmSelection() {
      setWallpaper(folderModel.get(list.currentIndex, "filePath"))
   }

   // Keyboard
   Keys.onLeftPressed: list.decrementCurrentIndex()
   Keys.onRightPressed: list.incrementCurrentIndex()
   Keys.onReturnPressed: confirmSelection()
   
   // Data
   FolderListModel {
      id: folderModel
      folder: "file://" + picker.dir
      nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.bmp", "*.PNG", "*.JPG", "*.JPEG", "*.WEBP", "*.GIF", "*.BMP"]
      showDirs: false
      sortField: folderlistmodel.Name
      onStatusChanged: picker.syncToCurrent
   }
   // List
   ListView {
      id: list
      anchors.fill: parent
      orientation: ListView.Horizontal
      model: folderModel
      spacing: picker.thumbSpacing
      clip: true
      cacheBuffer: 600
      leftMargin: width / 2 - picker.thumbW / 2
      

   }
}