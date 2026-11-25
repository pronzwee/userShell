import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import qs.services
import qs.theme
import qs.config

Rectangle {
   id: root

   property bool move: false
   
   width: 250
   height: 320
   color: Theme.inversePrimary
   y: savePos.posY
   x: savePos.posX
   radius: 20

   FileView {
      id: posStorage
      path: Quickshell.statePath("mpris_widget_pos.json")
      onAdapterUpdated: writeAdapter()

      JsonAdapter {
         id: savePos
         property real posX: 1600
         property real posY: 700
      }
   }

   ColumnLayout {
      anchors {
         horizontalCenter: parent.horizontalCenter
         top: parent.top
         topMargin: 9
         left: parent.left
         leftMargin: 8
      }
      spacing: 5

      Row {
         anchors.top: parent.top
         anchors.left: parent.left
         Text {
            text: "music_note"
            font {
               family: "Material Symbols Rounded"
               pixelSize: 23
               bold: true
               italic: true
            }
            color: Theme.text
         }
         Text {
            padding: 5
            text: "Music Player"
            font {
               family: "SF Pro Display"
               pixelSize: 16
               italic: true
               weight: 600
            }
            color: Theme.text
            opacity: 0.8
         }
      }

      Rectangle {
         width: root.width - 16
         height: root.height / 2.25
         radius: 17
         clip: true
         color: Theme.trans

         Image {
            id: img
            anchors.centerIn: parent
            source: MprisServ.trackArtUrl
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true

            layer.effect: OpacityMask {
               maskSource: Rectangle {
                  width: img.width
                  height: img.height
                  radius: 15
               }
            }
         }
      }
      Column {
         spacing: 5
         Text {
            text: MprisServ.trackTitle || "No Media"
            font {
               family: "SF Pro Display"
               pixelSize: 14
               bold: true
            }
            width: 220
            Layout.maximumWidth: parent.width
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
            color: Theme.text
            topPadding: 5
            leftPadding: 5
         }
      
         Text {
            text: MprisServ.trackArtist || "Unknow Artist"
            font {
               family: "SF Pro Display"
               pixelSize: 13
            }
            color: Theme.text
            opacity: 0.7
            leftPadding: 5
         }
      
         Row {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.horizontalCenterOffset: 20
            width: parent.width
            spacing: 10

            Rectangle {
               id: durRect1
               width: 200
               height: 4
               anchors.verticalCenter: parent.verticalCenter
               anchors.verticalCenterOffset: 15
               radius: 10
               color: Theme.text
               opacity: 1

               Rectangle {
                  id: durRect
                  anchors.verticalCenter: durRect1.verticalCenter
                  width: {
                     let dur = MprisServ.length > 0 ? MprisServ.length : 1
                     let pos = MprisServ.position
                     return Math.max(0, Math.min(parent.width, (pos / dur) * parent.width))
                  }
                  height: parent.height + 15
                  radius: 4
                  color: Theme.inversePrimary
                  Rectangle {
                     anchors.top: parent.top
                     anchors.right: parent.right
                     anchors.rightMargin: 4
                     width: 5
                     height: 20
                     radius: 7
                     color: Theme.primary
                  }

                  Waveform {
                     width: durRect.width - 14
                     waveColor: Theme.primary
                     frequency: 7
                     speed: 14500
                     lineWidth: 4
                     height: 12
                     y: 3
                  }
               }
            }
         }
      }

      Row {
         spacing: 10
         anchors.horizontalCenter: parent.horizontalCenter
         anchors.horizontalCenterOffset: 5
         topPadding: 27

         Rectangle {
            width: 27
            height: 27
            radius: 15
            color: Theme.text
            MouseArea {
               anchors.fill: parent
               cursorShape: Qt.PointingHandCursor
               onClicked: MprisServ.previous()
            }
            Text {
               text: "󰒮"
               font.pixelSize: 19
               color: Theme.background
               anchors.centerIn: parent
            }
         }
         Rectangle {
            width: 55
            height: 27
            radius: 6
            color: Theme.text
            MouseArea {
               anchors.fill: parent
               cursorShape: Qt.PointingHandCursor
               onClicked: MprisServ.togglePlayPause()
            }
            Text {
               text: MprisServ.isPlaying ? "" : ""
               font.pixelSize: 20
               // font.family: "Material Symbols Rounded"
               color: Theme.background
               anchors.centerIn: parent
            }
         }
         Rectangle {
            width: 27
            height: 27
            radius: 15
            color: Theme.text
            MouseArea {
               anchors.fill: parent
               cursorShape: Qt.PointingHandCursor
               onClicked: MprisServ.next()
            }
            Text {
               text: "󰒭"
               font.pixelSize: 19
               color: Theme.background
               anchors.centerIn: parent
            }
         }
      }
   }
   Item {
      anchors.top: parent.top
      width: root.width
      height: 30
      TapHandler {
         onDoubleTapped: {
            root.move = !root.move
         }
      }
      HoverHandler {
         cursorShape: root.move ? Qt.OpenHandCursor : Qt.PointingHandCursor
      }
   }
   DragHandler {
      id: handler
      target: root
      enabled: root.move
      xAxis.enabled: root.move
      yAxis.enabled: root.move
      onActiveChanged: {
         if (!handler.active) {
            savePos.posX = root.x
            savePos.posY = root.y
         }
      }
   }
}