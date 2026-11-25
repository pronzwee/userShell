import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import qs.modules
import qs.modules.lockscreen
import qs.theme
import qs.config
import qs.config.widget
import qs.services

ShellRoot {
   Variants {
      model: Quickshell.screens

      delegate: Scope {
         id: perScreen

         required property var modelData
         Island { id: island }
         Widget {}
         Menu {}
         CornerRadius {}
         Lockscreen {}
      }
   }
}