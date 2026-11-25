
import QtQuick
import Quickshell

Rectangle {
    id: root

    width: 300
    height: 150

    radius: 15
    color: "#dd1e1e2e"

    // TODO 1:
    // Buat property untuk menyimpan waktu sekarang.

    // TODO 2:
    // Buat Timer untuk update setiap 1 detik.

    Column {
        anchors.centerIn: parent
        spacing: 8

        Text {
            id: clockText

            // TODO 3:
            // Tampilkan jam dan menit.

            color: "white"
            font.pixelSize: 42
            font.bold: true
        }

        Text {
            id: dateText

            // TODO 4:
            // Tampilkan tanggal dan hari.

            color: "#aaaaaa"
            font.pixelSize: 15
        }
    }
}
