
import QtQuick

Item {
    id: root

    width: 165
    height: 20

    property color waveColor: "#89b4fa"
    property real amplitude: 0.8
    property real frequency: 2
    property real speed: 12000
    property real phase: 0
    property real lineWidth: 4

    NumberAnimation {
        target: root
        property: "phase"
        from: 0
        to: Math.PI * 2
        duration: root.speed
        loops: Animation.Infinite
        running: true
    }

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            const w = width
            const h = height
            const mid = h / 2

            ctx.clearRect(0, 0, w, h)

            if (w <= 0 || h <= 0)
                return

            const points = []
            const step = 1

            for (let x = 0; x <= w; x += step) {
                // Fixed spatial frequency
                const wave = Math.sin(
                    (x / 165) * Math.PI * frequency * 2
                    - root.phase
                )

                const y = mid +
                    wave * (h * 0.46) * amplitude

                points.push({ x, y })
            }

            ctx.beginPath()
            ctx.moveTo(points[0].x, points[0].y)

            for (let i = 1; i < points.length - 1; i++) {
                const xc = (points[i].x + points[i + 1].x) / 2
                const yc = (points[i].y + points[i + 1].y) / 2

                ctx.quadraticCurveTo(
                    points[i].x,
                    points[i].y,
                    xc,
                    yc
                )
            }

            const last = points[points.length - 1]
            ctx.lineTo(last.x, last.y)

            ctx.strokeStyle = root.waveColor
            ctx.lineWidth = root.lineWidth
            ctx.lineCap = "round"
            ctx.lineJoin = "round"
            ctx.stroke()
        }

        Connections {
            target: root

            function onPhaseChanged() { canvas.requestPaint() }
            function onAmplitudeChanged() { canvas.requestPaint() }
            function onFrequencyChanged() { canvas.requestPaint() }
            function onWaveColorChanged() { canvas.requestPaint() }
            function onLineWidthChanged() { canvas.requestPaint() }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
}
