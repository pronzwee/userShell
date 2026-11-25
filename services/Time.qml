pragma Singleton
import QtQuick
import Quickshell

Singleton {
   id: root

   SystemClock {
      id: clock
      precision: SystemClock.Seconds
   }

   readonly property string hours: Qt.formatDateTime(clock.date, "hh")
   readonly property string minutes: Qt.formatDateTime(clock.date, "mm")
   readonly property string seconds: Qt.formatDateTime(clock.date, "ss")
}