import QtQuick
import Quickshell
import Quickshell.Io

Item {
   property int memUsage: 0
   property real cpuUsage: 0.0
   property int updateInterval: 1000

   property double lastCpuTotal: 0
   property double lastCpuIdle: 0

   // Mem Proc
   Process {
      id: memProcess
      command: ["sh", "-c", "free | grep Mem"]
      running: true
      stdout: SplitParser {
         onRead: data => {
            if (!data) return
            var parts = data.trim().split(/\s+/)
            var total = parseInt(parts[1]) || 1
            var used = parseInt(parts[2]) || 0
            memUsage = Math.round((used / total) * 100) / 2
         }
      }
   }

   // Cpu Proc
   Process {
      id: cpuProcess
      command: ["sh", "-c", "head -1 /proc/stat"]
      running: true
      stdout: SplitParser {
         onRead: data => {
            if (!data) return
            var parts = data.trim().split(/\s+/)
            var nums = parts.slice(1, 8).map(Number)
            var idle = nums[3]
            var total = nums.reduce((a, b) => a + b, 0)
            
            if (lastCpuTotal > 0) {
               var diffTotal = total - lastCpuTotal
               var diffIdle = idle - lastCpuIdle
               if (diffTotal > 0) {
                  cpuUsage = Math.round((1 - diffIdle / diffTotal) * 100)
               }
            }
            lastCpuTotal = total
            lastCpuIdle = idle
         }
      }
   }

   Timer {
      interval: updateInterval
      running: true
      repeat: true
      onTriggered: {
         memProcess.running = false
         memProcess.running = true

         cpuProcess.running = false
         cpuProcess.running = true
      }
   }
}