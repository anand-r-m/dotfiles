import QtQuick
import Quickshell
import Quickshell.Io

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18
  property var info: []

  Process {
    id: proc
    command: ["sh", "-c", "hostname; uname -r; uptime -p | sed 's/^up //'; grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs; free -h | awk '/Mem/{print $2}'; pacman -Q | wc -l; hyprctl version | head -1 | awk '{print $2}'"]
    stdout: StdioCollector { onStreamFinished: page.info = this.text.split("\n") }
  }
  Component.onCompleted: proc.running = true

  BarText { text: "About"; font { pixelSize: 24; bold: true } }

  Row {
    spacing: 24
    BarText { text: "\uf303"; font.pixelSize: 72; color: Colors.primary }
    Column {
      anchors.verticalCenter: parent.verticalCenter
      spacing: 4
      BarText { text: "Arch Linux"; font { pixelSize: 22; bold: true } }
      BarText { text: "Lenovo ThinkPad E14 Gen 2  ·  " + (page.info[0] ?? ""); color: Colors.dim }
    }
  }

  SettingsCard {
    title: "SYSTEM"
    Repeater {
      model: [
        { k: "Processor",    v: page.info[3] },
        { k: "Memory",       v: page.info[4] },
        { k: "Kernel",       v: page.info[1] },
        { k: "Hyprland",     v: page.info[6] },
        { k: "Packages",     v: page.info[5] },
        { k: "Uptime",       v: page.info[2] }
      ]
      Item {
        required property var modelData
        width: parent.width; height: 24
        BarText { text: modelData.k; color: Colors.dim }
        BarText { anchors.right: parent.right; text: modelData.v ?? ""; font.bold: true }
      }
    }
  }
}
