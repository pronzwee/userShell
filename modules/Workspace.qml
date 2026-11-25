import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts

import qs.theme

RowLayout {
   id: root

   Repeater {
      model: 5
      delegate: Component {
         Rectangle {
            id: wsButton

            required property var modelData
            property var ws: modelData + 1
            property var isActive: Hyprland.focusedWorkspace?.id === ws

            width: isActive ? 28 : 25
            height: isActive ? 28 : 25
            radius: 20
            color: isActive ? "red" : "blue"

            Text {
               text: ws
               color: Theme.accent
               anchors.centerIn: parent
            }
         }
      }
   }
}