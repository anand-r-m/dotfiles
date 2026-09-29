import QtQuick
import Quickshell
import Quickshell.Io

Row {
  spacing: 14
  property bool dnd: false
  property bool night: false

  Process {
    id: check
    command: ["sh", "-c", "makoctl mode | grep -q do-not-disturb && echo dnd; pgrep -x hyprsunset > /dev/null && echo night"]
    stdout: StdioCollector {
      onStreamFinished: {
        dnd = this.text.includes("dnd")
        night = this.text.includes("night")
      }
    }
  }

  Timer { interval: 3000; running: true; repeat: true; triggeredOnStart: true; onTriggered: check.running = true }
  Timer { id: recheck; interval: 400; onTriggered: check.running = true }

  BarText {
    text: "\uf186"
    color: night ? Colors.accent : Colors.dim
    MouseArea {
      anchors.fill: parent
      onClicked: { Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset || hyprsunset -t 4500"]); recheck.restart() }
    }
  }

  BarText {
    text: dnd ? "\uf1f6" : "\uf0f3"
    color: dnd ? Colors.accent : Colors.dim
    MouseArea {
      anchors.fill: parent
      onClicked: { Quickshell.execDetached(["makoctl", "mode", "-t", "do-not-disturb"]); recheck.restart() }
    }
  }
}
