import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import qs.theme
import qs.config

PanelWindow {
    id: root

    property int barH: 600
    property bool active: false
    
    anchors { bottom: true; left: true; right: true }
    implicitHeight: barH
    exclusiveZone: 0
    color: Theme.trans
    mask: Region { item: button }
    exclusionMode: "Ignore"

    RowLayout {
        id: layoutItem
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        spacing: 0
        Rectangle {
            id: curve

            property int radius: 20
            Layout.alignment: Qt.AlignBottom
            anchors.left: parent.left
            Layout.bottomMargin: content.Layout.bottomMargin / 2
            width: radius
            height: radius
            color: Theme.trans

            Curve {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                isTop: false
                mirrored: true
                radius: curve.width
            }
        }

        Rectangle {
            id: content
            Layout.alignment: Qt.AlignBottom
            Layout.bottomMargin: root.active ? 0 : -50
            width: 700
            height: 50
            topLeftRadius: 15
            topRightRadius: 15
            color: Theme.bg
            Behavior on Layout.bottomMargin {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: 10
                radius: 10
                height: 25
                width: parent.width - 20
                Layout.fillWidth: true
                color: Theme.trans
                RowLayout {
                    spacing: 0
                    Repeater {
                        model: ["Menu", "Dashboard", "Wallpapers", "Resource"]
                        delegate: Component {
                            Rectangle {
                                required property var modelData
                                Layout.preferredWidth: (content.width / 4) - (20 / 4)
                                Layout.preferredHeight: 25
                                color: Theme.background
                                radius: 8
                                Text {
                                    text: modelData
                                    anchors.centerIn: parent
                                    color: Theme.text
                                }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignBottom
            anchors.right: parent.right
            Layout.bottomMargin: content.Layout.bottomMargin / 2
            width: curve.radius
            height: curve.radius
            color: Theme.trans

            Curve {
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                isTop: false
                mirrored: false
                radius: curve.radius
            }
        }
    }
    IpcHandler {
        target: "menu"
        function toggle(): void {
            root.active = !root.active
        }
    }
}