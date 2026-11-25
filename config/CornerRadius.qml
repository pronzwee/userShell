import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.theme

Scope {
   id: root

   property int radius: 28
   property color color: "#000"

   PanelWindow {
      anchors { top: true; left: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: "Overlay"
      width: radius * 3
      height: radius * 3
      mask: Region {}
      color: "transparent"
      Curve {
         anchors { top: parent.top; left: parent.left }
         isTop: true
         mirrored: false
         color: root.color
         radius: root.radius
      }
   }
   PanelWindow {
      anchors { top: true; right: true }
      exclusionMode: "Ignore"
      WlrLayershell.layer: "Overlay"
      width: radius * 3
      height: radius * 3
      mask: Region {}
      color: "transparent"
      Curve {
         anchors { top: parent.top; right: parent.right }
         isTop: true
         mirrored: true
         color: root.color
         radius: root.radius
      }
   }
   PanelWindow {
      anchors { bottom: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: "Overlay"
      width: radius * 3
      height: radius * 3
      mask: Region {}
      color: "transparent"
      Curve {
         anchors { bottom: parent.bottom; right: parent.right }
         isTop: false
         mirrored: true
         color: root.color
         radius: root.radius
      }
   }
   PanelWindow {
      anchors { bottom: true; left: true }
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: "Overlay"
      width: radius * 3
      height: radius * 3
      mask: Region {}
      color: "transparent"
      Curve {
         anchors { bottom: parent.bottom; left: parent.left }
         isTop: false
         mirrored: false
         color: root.color
         radius: root.radius
      }
   }
}