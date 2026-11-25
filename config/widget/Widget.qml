import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.theme
import qs.services

PanelWindow {
   id: root
   anchors { top: true; left: true; right: true; bottom: true }
   color: Theme.trans
   WlrLayershell.layer: "Bottom"
   exclusionMode: "Ignore"
   MprisWidget {}
}