import QtQuick
import Quickshell
import Quickshell.Io

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18
  property real bright: 0.5
  property bool night: false
  property int temp: 4500

  Process {
    id: check
    command: ["sh", "-c", "brightnessctl -m; pgrep -x hyprsunset > /dev/null && echo NIGHT"]
    stdout: StdioCollector {
      onStreamFinished: {
        const pct = parseInt(this.text.split("\n")[0].split(",")[3])
        if (!isNaN(pct)) page.bright = pct / 100
        page.night = this.text.includes("NIGHT")
      }
    }
  }
  Component.onCompleted: check.running = true

  Timer {
    id: applyTemp
    interval: 300
    onTriggered: Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset; sleep 0.2; hyprsunset -t " + page.temp])
  }

  BarText { text: "Display"; font { pixelSize: 24; bold: true } }

  SettingsCard {
    title: "BRIGHTNESS"
    Item {
      width: parent.width; height: 18
      BarText { text: "\uf185  Screen brightness" }
      BarText { anchors.right: parent.right; text: Math.round(page.bright * 100) + "%"; color: Colors.primary; font.bold: true }
    }
    SliderBar {
      width: parent.width
      value: page.bright
      onMoved: v => {
        page.bright = Math.max(0.02, v)
        Quickshell.execDetached(["brightnessctl", "set", Math.round(page.bright * 100) + "%"])
      }
    }
  }

  SettingsCard {
    title: "NIGHT LIGHT"
    Item {
      width: parent.width; height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "\uf186  Warmer colors to reduce eye strain" }
      ToggleSwitch {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        checked: page.night
        onToggled: {
          page.night = !page.night
          Quickshell.execDetached(["sh", "-c", page.night ? "hyprsunset -t " + page.temp : "pkill -x hyprsunset"])
        }
      }
    }
    Item {
      width: parent.width; height: 18
      BarText { text: "Warmth"; color: Colors.dim }
      BarText { anchors.right: parent.right; text: page.temp + "K"; color: Colors.primary; font.bold: true }
    }
    SliderBar {
      width: parent.width
      value: 1 - (page.temp - 3000) / 3500
      onMoved: v => {
        page.temp = Math.round(3000 + (1 - v) * 3500)
        if (page.night) applyTemp.restart()
      }
    }
  }

  SettingsCard {
    title: "SCREENS"
    Repeater {
      model: Quickshell.screens
      Item {
        required property var modelData
        width: parent.width; height: 22
        BarText { text: "\uf108  " + modelData.name }
        BarText { anchors.right: parent.right; text: modelData.width + " × " + modelData.height; color: Colors.dim }
      }
    }
  }
}
