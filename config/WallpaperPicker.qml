import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import Qt.labs.folderlistmodel

import qs.theme

// Carousel wallpaper: item terpilih selalu di tengah.
// Kontrol: drag / scroll mouse / panah kiri-kanan / klik / Enter.
FocusScope {
    id: picker

    property string dir: Quickshell.env("HOME") + "/Pictures/Wallpapers"
    property string current: ""          // wallpaper yang sedang aktif
    property string transitionType: "random"

    property int thumbW: 150
    property int thumbH: 84
    property int thumbRadius: 14
    property int thumbSpacing: 10

    property bool synced: false

    focus: true

    // Awww
    Process { id: setter }
    Process {
        id: kittyReload

        stdout: StdioCollector {}
        stderr: StdioCollector {}

        onExited: (code, status) => {
            if (code !== 0)
                console.error("Kitty reload gagal:", code)
        }
    }
    Process {
        id: matugen
    
        stdout: StdioCollector {}
        stderr: StdioCollector {}
    
        onExited: (code, status) => {
            if (code === 0) {
                console.log("Matugen berhasil generate warna")
    
                kittyReload.command = [
                    "/usr/bin/kitty",
                    "@",
                    "--to",
                    "unix:/tmp/kitty-socket",
                    "set-colors",
                    "--all",
                    "--configured",
                    Quickshell.env("HOME") + "/.config/kitty/matugen-colors.conf"
                ]
    
                kittyReload.running = true
            } else {
                console.error("Matugen gagal:", code)
            }
        }
    }

    function setWallpaper(path) {
        if (!path) return

        picker.current = path
        setter.running = false
        setter.command = [
            "awww", "img", path,
            "--transition-type", picker.transitionType,
            "--transition-duration", "0.8",
            "--transition-fps", "100"
        ]
        setter.running = true

        matugen.running = false
        matugen.command = [
            "/usr/bin/matugen",
            "image",
            "--source-color-index",
            "0",
            path
        ]
        matugen.running = true
    }

    // Baca wallpaper aktif dari awww supaya posisi awal sesuai
    Process {
        id: query
        command: ["awww", "query"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/image:\s*(.+)/)
                if (m) {
                    picker.current = m[1].trim()
                    picker.syncToCurrent()
                }
            }
        }
    }

    function syncToCurrent() {
        if (synced || current === ""
            || folderModel.status !== FolderListModel.Ready
            || folderModel.count === 0)
            return

        for (let i = 0; i < folderModel.count; i++) {
            if (folderModel.get(i, "filePath") === current) {
                list.currentIndex = i
                break
            }
        }
        synced = true
    }

    function confirmSelection() {
        setWallpaper(folderModel.get(list.currentIndex, "filePath"))
    }

    // ---------- keyboard ----------
    Keys.onLeftPressed: list.decrementCurrentIndex()
    Keys.onRightPressed: list.incrementCurrentIndex()
    Keys.onReturnPressed: confirmSelection()
    Keys.onEnterPressed: confirmSelection()
    Keys.onSpacePressed: confirmSelection()
    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) { list.currentIndex = 0; event.accepted = true }
        else if (event.key === Qt.Key_End) { list.currentIndex = folderModel.count - 1; event.accepted = true }
    }

    // ---------- data ----------
    FolderListModel {
        id: folderModel
        folder: "file://" + picker.dir
        nameFilters: [
            "*.png", "*.jpg", "*.jpeg", "*.webp", "*.gif", "*.bmp",
            "*.PNG", "*.JPG", "*.JPEG", "*.WEBP", "*.GIF", "*.BMP"
        ]
        showDirs: false
        sortField: FolderListModel.Name
        onStatusChanged: picker.syncToCurrent()
    }

    // ---------- list ----------
    ListView {
        id: list
        anchors.fill: parent

        orientation: ListView.Horizontal
        model: folderModel
        spacing: picker.thumbSpacing
        clip: true
        cacheBuffer: 600

        // Item terpilih selalu di tengah
        leftMargin: width / 2 - picker.thumbW / 2
        rightMargin: width / 2 - picker.thumbW / 2
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: width / 2 - picker.thumbW / 2
        preferredHighlightEnd: width / 2 + picker.thumbW / 2
        highlightMoveDuration: 300
        snapMode: ListView.SnapOneItem
        boundsBehavior: Flickable.StopAtBounds
        keyNavigationEnabled: false

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                if (wheelCooldown.running) return
                const d = event.angleDelta.y !== 0 ? event.angleDelta.y : event.angleDelta.x
                if (d > 0) list.decrementCurrentIndex()
                else if (d < 0) list.incrementCurrentIndex()
                wheelCooldown.start()
            }
        }
        Timer { id: wheelCooldown; interval: 110 }

        delegate: Item {
            id: item

            required property int index
            required property string filePath
            required property url fileUrl
            required property string fileName

            readonly property bool selected: ListView.isCurrentItem
            readonly property bool applied: picker.current === filePath

            width: picker.thumbW
            height: ListView.view.height

            ClippingRectangle {
                id: card
                anchors.centerIn: parent
                width: picker.thumbW
                height: picker.thumbH
                radius: picker.thumbRadius
                color: Qt.rgba(1, 1, 1, 0.06)

                border.width: item.selected ? 2 : 0
                border.color: Theme.accent

                scale: item.selected ? 1.0 : 0.82
                opacity: item.selected ? 1.0 : (mouse.containsMouse ? 0.9 : 0.55)

                Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }
                Behavior on opacity { NumberAnimation { duration: 200 } }

                Image {
                    id: img
                    anchors.fill: parent
                    source: item.fileUrl
                    sourceSize: Qt.size(picker.thumbW * 2, picker.thumbH * 2)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    mipmap: true
                    opacity: status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 250 } }
                }

                // Penanda wallpaper yang sedang aktif
                Rectangle {
                    visible: item.applied
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 6
                    width: 10
                    height: 10
                    radius: 9
                    color: Qt.rgba(1, 1, 1, 0.95)
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    picker.forceActiveFocus()
                    list.currentIndex = item.index
                    picker.setWallpaper(item.filePath)
                }
            }
        }
    }

    // Fade kiri & kanan
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 60
        radius: 15
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Theme.bg }
            GradientStop { position: 1.0; color: Qt.alpha(Theme.bg, 0) }
        }
    }
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 60
        radius: 15
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop { position: 0.0; color: Qt.alpha(Theme.bg, 0) }
            GradientStop { position: 1.0; color: Theme.bg }
        }
    }

    // Folder kosong
    Text {
        anchors.centerIn: parent
        visible: folderModel.status === FolderListModel.Ready && folderModel.count === 0
        text: "Tidak ada gambar di " + picker.dir
        color: Qt.rgba(1, 1, 1, 0.6)
        font.pixelSize: 12
    }
}
