import QtQuick
import Quickshell

import qs.services
import qs.theme

Rectangle {
   id: root
   width: 200
   height: 200
   radius: 20
   x: 30
   y: 500
   Resources {
      id: resource
      updateInterval: 1
   }

   Text {
      anchors.centerIn: parent
      text: resource.memUsage
      color: Theme.bg
   }

   MouseArea {
      anchors.fill: parent
      drag.target: root
      drag.axis: Drag.XAndYAxis
      cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
   }
}