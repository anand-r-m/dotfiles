import QtQuick
import Quickshell.Io

Row {
  spacing: 14
  property int cpu: 0
  property int mem: 0
  property real lastIdle: 0
  property real lastTotal: 0

  Process {
    id: proc
    command: ["sh", "-c", "head -1 /proc/stat; grep -E 'MemTotal|MemAvailable' /proc/meminfo"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.split("\n")
        const p = lines[0].trim().split(/\s+/).slice(1).map(Number)
        const idle = p[3] + p[4]
        const total = p.reduce((a, b) => a + b, 0)
        if (lastTotal > 0) cpu = Math.round(100 * (1 - (idle - lastIdle) / (total - lastTotal)))
        lastIdle = idle; lastTotal = total
        const memTotal = Number(lines[1].match(/\d+/)[0])
        const memAvail = Number(lines[2].match(/\d+/)[0])
        mem = Math.round(100 * (memTotal - memAvail) / memTotal)
      }
    }
  }

  Timer {
    interval: 2000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: proc.running = true
  }

  Row { spacing: 6
    BarText { text: "CPU"; color: Colors.dim; font.bold: true }
    BarText { text: cpu + "%"; color: Colors.primary }
  }
  Row { spacing: 6
    BarText { text: "RAM"; color: Colors.dim; font.bold: true }
    BarText { text: mem + "%"; color: Colors.primary }
  }
}
