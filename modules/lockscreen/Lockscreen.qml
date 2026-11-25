import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import qs.theme

WlSessionLock {
   id: lock
   locked: LockscreenState.locked
   onLockedChanged: {
      if (LockscreenState.locked !== locked) {
         LockscreenState.locked = locked
      }
   }
   WlSessionLockSurface {
      id: surface
      Rectangle {
         id: mainContainer
         anchors.fill: parent
         color: "#000"
         opacity: LockscreenState.locked ? 1 : 0
         Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
         }
      }
      Item {
         id: card
         width: 500
         height: 500
         anchors.centerIn: parent
         property real baseX: (parent.width - width) / 2
         property real animOffsetX: 0

         transform: Translate { x: card.animOffsetX }

         opacity: LockscreenState.locked ? 1 : 0
         scale: LockscreenState.locked ? 1.0 : 0.8
         y: LockscreenState.locked ? (parent.height - height) / 2 : (parent.height - height) / 2

         Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic }}
         Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutCubic; easing.overshoot: 1.2 }}
         Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutCubic }}

         SequentialAnimation {
            id: shakeAnim
            NumberAnimation { target: card; property: "animOffsetX"; to: -12; duration: 50; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "animOffsetX"; to: 12; duration: 50; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "animOffsetX"; to: -8; duration: 50; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "animOffsetX"; to: 8; duration: 50; easing.type: Easing.OutCubic }
            NumberAnimation { target: card; property: "animOffsetX"; to: 0; duration: 50; easing.type: Easing.OutCubic }
         }
         Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            Text {
               id: clockText
               anchors.horizontalCenter: parent.horizontalCenter
               text: Qt.formatTime(currentTime, "hh:mm")
               font.pixelSize: 80
               font.weight: 800
               color: Theme.text

               property date currentTime: new Date()

               Timer {
                  interval: 1000
                  running: true
                  repeat: true
                  onTriggered: clockText.currentTime = new Date()
               }
            }

            Text {
               anchors.horizontalCenter: parent.horizontalCenter
               text: Qt.formatDate(new Date(), "dddd, MMMM d")
               font.pixelSize: 16
               font.weight: 700
               color: Qt.rgba(1,1,1,0.75)
            }
            Item { width: 1; height: 13}

            Rectangle {
               id: fieldWrap
               width: parent.width
               height: 50
               radius: 15
               color: Theme.accent
               border.width: pwField.activeFocus ? 2 : (LockscreenState.authFailed ? 2 : 1)
               border.color: LockscreenState.authFailed ? Theme.bg : Theme.error
               Behavior on border.color { ColorAnimation { duration: 200 }}
               Behavior on border.width { NumberAnimation { duration: 150 }}
               RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: 18
                  anchors.rightMargin: 18
                  spacing: 10

                  TextField {
                     id: pwField
                     Layout.fillWidth: true
                     echoMode: TextInput.Password
                     enabled: !LockscreenState.authentication
                     placeholderText: LockscreenState.authentication ? "Verifying..." : "Enter Password"
                     placeholderTextColor: Theme.primary
                     color: "red"
                     background: null
                     font.pixelSize: 14
                     verticalAlignment: TextInput.AlignVCenter
                     onAccepted: {
                        if (text.length > 0)
                        LockscreenState.authenticate(text)
                     }
	    	         }

                  BusyIndicator {
                     visible: LockscreenState.authentication
                     running: LockscreenState.authentication
                     implicitHeight: 18
                     implicitWidth: 18
                  }
               }
            }
            Text {
               anchors.horizontalCenter: parent.horizontalCenter
               text: "incorrect password"
               color: Theme.error
               font.pixelSize: 13
               font.weight: 600
               opacity: LockscreenState.authFailed ? 1 : 0
               Behavior on opacity {
                  NumberAnimation { duration: 200; easing.type: Easing.InOutSine }
               }
            }
         }
         Connections {
            target: LockscreenState
            function onAuthFailedChanged() {
               if (LockscreenState.authFailed) {
                  shakeAnim.start()
                  pwField.text = ""
                  pwField.forceActiveFocus()
               }
            }
            function onLockedChanged() {
               if (LockscreenState.locked) {
                  pwField.text = ""
               } else {
                  pwField.forceActiveFocus()
               }
            }
         }
         Component.onCompleted: pwField.forceActiveFocus()
      }
   }
}
