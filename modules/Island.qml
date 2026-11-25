import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import qs.theme
import qs.config
import qs.services

ShellRoot {
   id: root

   readonly property bool isPlaying: Cava.total !== 0
   property int barHeight: root.bc.height !== undefined ? root.bc.height : 60
   property int barWidth: root.bc.width !== undefined ? root.bc.width : 700
   property bool floating: root.bc.floating !== undefined ? root.bc.floating : true
   property bool isHover: false
   property color barColor: Theme.bg
   property bool visualizerShown: false
   property var bc: ({})

   Process {
      id: configProc
      command: ["cat", "~/.config/quickshell/shell/config/bar/bar.json"]
      running: true
      stdout: StdioCollector {
         onStreamFinished: {
            if (text.trim() !== "") {
               try {
                  root.bc = JSON.parse(text);
               } catch (e) {}
            }
         }
      }
   }
   Timer {
      interval: 1000
      running: true
      repeat: true
      onTriggered: configProc.running = true
   }
   
   onIsPlayingChanged: {
      if (isPlaying) visualizerShown = true
   }
   Timer {
      interval: 1000
      repeat: false
      running: !isPlaying
      onTriggered: visualizerShown = false
   }
   Resources {
      id: resource
      updateInterval: 1000
   }

   Variants {
      model: Quickshell.screens

      PanelWindow {
         required property var modelData

         anchors { top: true }
         implicitHeight: barHeight
         implicitWidth: barWidth
         exclusiveZone: 38
         color: Theme.trans
         mask: Region { item: content }
         WlrLayershell.layer: WlrLayer.Top

         // Dynamic Island Content
         Rectangle {
            id: content
            anchors.horizontalCenter: parent.horizontalCenter
            width: contentLayout.implicitWidth
            height: contentLayout.implicitHeight
            color: Theme.trans

            RowLayout {
               id: contentLayout
               anchors.horizontalCenter: parent.horizontalCenter
               spacing: 0

               Row {
                  id: island

                  anchors.top: parent.top
                  scale: isHover ? 1.1 : 1 + ((Cava.levels[Cava.bars / 2] - Cava.levels[0]) / 46)
                  y: isHover ? 3 : 0
                  Behavior on scale {
                     NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                  }
                  Behavior on y {
                     NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                  }
                  
                  Rectangle {
                     anchors.top: parent.top
                     width: 40
                     height: 40
                     color: Theme.trans
                     Curve {
                        anchors.top: parent.top
                        anchors.right: parent.right
                        mirrored: true
                        isTop: true
                        radius: 12
                        visible: !floating
                     }
                  }
                  // Center Bar
                  Rectangle {
                     id: cenBar
                     anchors.top: parent.top
                     anchors.topMargin: floating ? 6 + (Cava.levels[Cava.bars / 2] - Cava.levels[0]) * 3 : 0
                     width: {
                        if (visualizer.spacing !== -3.99) return 180
                        return 120
                     }
                     height: floating ? 40 : 45
                     color: Theme.bg
                     bottomLeftRadius: floating ? 25 : 20
                     bottomRightRadius: floating ? 25 : 20
                     topLeftRadius: floating ? 25 : 0
                     topRightRadius: floating ? 25 : 0
                     Behavior on width {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                     }

                     Row {
                        id: visualizer
                        anchors.centerIn: parent
                        spacing: visualizerShown ? 4 : -3.99
                        Behavior on spacing {
                           NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                        }

                        Repeater {
                           model: Cava.levels

                           delegate: Rectangle {
                              required property real modelData
                              required property int index
                              
                              anchors.verticalCenter: parent.verticalCenter
                              anchors.verticalCenterOffset: {
                                 if (visualizer.spacing !== -3.99) return 0
                                 if (index === 0) return -2.5
                                 if (index === Cava.bars -1) return 4
                                 return 0
                              }
                              Behavior on anchors.verticalCenterOffset {
                                 NumberAnimation { duration: 250; easing.type: Easing.OutBack }
                              }
                              width: 4
                              height: Math.max(4, modelData * 24)
                              radius: 3
                              color: {
                                 if (index === 0 || index === Cava.bars - 1) return Theme.fg
                                 if (visualizer.spacing !== -3.99) return Theme.fg
                                 return Theme.trans
                              }
                              scale: {
                                 if (visualizer.spacing !== -3.99) return 1
                                 return 0.87
                              }
                           }
                        }
                     }

                     Text {
                        anchors.right: visualizer.left
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1
                        text: Time.hours
                        color: Theme.fg
                        font {
                           family: "SF Pro Display"
                           weight: {
                              if (visualizer.spacing !== -3.99) return 650
                              return 700
                           }
                           pixelSize: {
                              if (visualizer.spacing !== -3.99) return 18
                              return 15
                           }
                        }
                     }
                     Text {
                        anchors.left: visualizer.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.verticalCenterOffset: 1
                        text: Time.minutes
                        color: Theme.fg
                        font {
                           family: "SF Pro Display"
                           weight: {
                              if (visualizer.spacing !== -3.99) return 650
                              return 700
                           }
                           pixelSize: {
                              if (visualizer.spacing !== -3.99) return 18
                              return 15
                           }
                        }
                     }

                     MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: isHover = true
                        onExited: isHover = false
                     }
                  }
                  Rectangle {
                     anchors.top: parent.top
                     width: 40
                     height: 40
                     color: Theme.trans
                     Curve {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        mirrored: false
                        isTop: true
                        radius: 12
                        visible: !floating
                     }
                  }
               }
            }
         } // Dynamic Island Content end
         IpcHandler {
            target: "islandMode"
            function toggle(): void {
               root.floating = !root.floating
            }
         }
      }
   }
}