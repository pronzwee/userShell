
import QtQuick
import QtQuick.Shapes
import qs.theme
import qs.services

Item {
   id: waveRoot
   width: 200
   height: {
      if (!Cava.levels[0]) return 30
      return 80
   }

   property color color: Theme.primary
   property real phase: 0
   property var audio: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

   NumberAnimation on phase {
      from: 0
      to: Math.PI * 2
      duration: 5000
      loops: Animation.Infinite
   }

   Behavior on height {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
   }

   Connections {
      target: Cava
      function onLevelsChanged() {
         let values = []
         for (let i = 0; i < 10; i++)
            values.push(Cava.levels[i] ?? 0)
         waveRoot.audio = values
      }
   }

   function level(i) {
      let a = audio[Math.max(0, i - 1)]
      let b = audio[i]
      let c = audio[Math.min(9, i + 1)]
      return (a + b * 2 + c) / 4
   }

   Shape {
      anchors.fill: parent
      antialiasing: true
      preferredRendererType: Shape.CurveRenderer
      opacity: 0.25

      ShapePath {
         fillColor: waveRoot.color
         strokeColor: "transparent"
         strokeWidth: 0
         startX: 0
         startY: waveRoot.height

         PathLine { x: 0; y: 25 }

         PathCurve { x: waveRoot.width * 0.15; y: 25 - (waveRoot.level(0) * 25 + Math.sin(waveRoot.phase) * 1.5 + 2) }
         PathCurve { x: waveRoot.width * 0.30; y: 25 - (waveRoot.level(2) * 30 + Math.sin(waveRoot.phase + 0.8) * 1.5 + 3) }
         PathCurve { x: waveRoot.width * 0.45; y: 25 - (waveRoot.level(4) * 35 + Math.sin(waveRoot.phase + 1.5) * 1.5 + 4) }
         PathCurve { x: waveRoot.width * 0.60; y: 25 - (waveRoot.level(6) * 30 + Math.sin(waveRoot.phase + 2.2) * 1.5 + 3) }
         PathCurve { x: waveRoot.width * 0.75; y: 25 - (waveRoot.level(8) * 25 + Math.sin(waveRoot.phase + 3) * 1.5 + 2) }
         PathCurve { x: waveRoot.width * 0.90; y: 25 - (waveRoot.level(9) * 22 + Math.sin(waveRoot.phase + 3.8) * 1.5 + 2) }
         PathCurve { x: waveRoot.width; y: 25 }
         PathLine { x: waveRoot.width; y: waveRoot.height }
         PathLine { x: 0; y: waveRoot.height }
      }
   }
}
