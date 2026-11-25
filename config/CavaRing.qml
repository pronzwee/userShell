import QtQuick
import qs.theme
import qs.services

Item {
   id: root
   width: 240
   height: 240

   property int count: 36
   property real innerRadius: 60
   property real maxBar: 50
   property real barWidth: 5
   property color barColor: Theme.primary

   Repeater {
      model: root.count

      Item {
         required property int index

         x: root.width / 2
         y: root.height / 2
         width: 0
         height: 0
         rotation: index * 360 / root.count

         Rectangle {
            property real v: Cava.levels[index % Math.max(1, Cava.levels.length)] ?? 0

            width: root.barWidth
            height: Math.max(4, v * root.maxBar)
            radius: width / 2
            color: root.barColor
            x: -width / 2
            y: -(root.innerRadius + height)

            Behavior on height {
               NumberAnimation { duration: 80 }
            }
         }
      }
   }
}