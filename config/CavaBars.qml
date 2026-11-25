import QtQuick
import qs.theme
import qs.services

Item {
   id: root
   width: 300
   height: 100

   property int count: 20
   property real gap: 4
   property color barColor: Theme.primary
   property real barW: (width - gap * (count - 1)) / count

   Repeater {
      model: root.count

      Rectangle {
         required property int index

         width: root.barW
         height: Math.max(4, (Cava.levels[index] ?? 0) * root.height)
         x: index * (root.barW + root.gap)
         y: root.height - height
         radius: width / 2
         color: root.barColor

         Behavior on height {
            NumberAnimation { duration: 80 }
         }
      }
   }
}