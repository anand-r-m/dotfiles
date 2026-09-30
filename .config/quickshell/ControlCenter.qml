import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire

Pill {
  id: root
  property real bright: 0.5
  property bool wifi: true
  property bool night: false
  property bool dnd: false
  property var sink: Pipewire.defaultAudioSink
  property var adapter: Bluetooth.defaultAdapter

  PwObjectTracker { objects: [root.sink] }

  function refresh() { stateProc.running = true }

  Process {
    id: stateProc
    command: ["sh", "-c", "brightnessctl -m; nmcli radio wifi; makoctl mode | grep -q do-not-disturb && echo DND; pgrep -x hyprsunset > /dev/null && echo NIGHT"]
    stdout: StdioCollector {
      onStreamFinished: {
        const lines = this.text.split("\n")
        const pct = parseInt(lines[0].split(",")[3])
        if (!isNaN(pct)) root.bright = pct / 100
        root.wifi = lines[1].trim() === "enabled"
        root.dnd = this.text.includes("DND")
        root.night = this.text.includes("NIGHT")
      }
    }
  }
  Timer { id: recheck; interval: 400; onTriggered: root.refresh() }

  BarText {
    id: icon
    text: "\uf013"
    font.pixelSize: 14
    MouseArea { anchors.fill: parent; onClicked: { if (!panel.visible) root.refresh(); panel.toggle() } }
  }

  DropPanel {
    id: panel
    anchorItem: icon
    panelWidth: 340

    BarText { text: "Quick settings"; font.bold: true }

    // Brightness
    Column {
      width: parent.width
      spacing: 8
      Item {
        width: parent.width; height: 18
        BarText { text: "\uf185  Brightness" }
        BarText { anchors.right: parent.right; text: Math.round(root.bright * 100) + "%"; color: Colors.primary; font.bold: true }
      }
      SliderBar {
        width: parent.width
        value: root.bright
        onMoved: v => {
          root.bright = Math.max(0.02, v)
          Quickshell.execDetached(["brightnessctl", "set", Math.round(root.bright * 100) + "%"])
        }
      }
    }

    // Volume
    Column {
      width: parent.width
      spacing: 8
      Item {
        width: parent.width; height: 18
        BarText { text: "\uf028  Volume" }
        BarText {
          anchors.right: parent.right
          text: (root.sink?.audio?.muted ?? false) ? "muted" : Math.round((root.sink?.audio?.volume ?? 0) * 100) + "%"
          color: Colors.primary; font.bold: true
        }
      }
      SliderBar {
        width: parent.width
        value: root.sink?.audio?.volume ?? 0
        dimmed: root.sink?.audio?.muted ?? false
        onMoved: v => { if (root.sink) root.sink.audio.volume = v }
      }
    }

    // Toggle tiles
    Grid {
      width: parent.width
      columns: 2
      spacing: 10
      Tile {
        width: (parent.width - 10) / 2
        icon: "\uf1eb"; label: "Wi-Fi"; active: root.wifi
        onClicked: { root.wifi = !root.wifi; Quickshell.execDetached(["nmcli", "radio", "wifi", root.wifi ? "on" : "off"]) }
      }
      Tile {
        width: (parent.width - 10) / 2
        icon: "\uf293"; label: "Bluetooth"; active: root.adapter?.enabled ?? false
        onClicked: if (root.adapter) root.adapter.enabled = !root.adapter.enabled
      }
      Tile {
        width: (parent.width - 10) / 2
        icon: "\uf186"; label: "Night light"; active: root.night
        onClicked: { Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset || hyprsunset -t 4500"]); recheck.restart() }
      }
      Tile {
        width: (parent.width - 10) / 2
        icon: "\uf1f6"; label: "Do not disturb"; active: root.dnd
        onClicked: { Quickshell.execDetached(["makoctl", "mode", "-t", "do-not-disturb"]); recheck.restart() }
      }
    }

    // Shortcut buttons
    Row {
      width: parent.width
      spacing: 8
      Repeater {
        model: [
          { label: "Audio",      cmd: ["pavucontrol"] },
          { label: "Appearance", cmd: ["nwg-look"] },
          { label: "Wallpaper",  cmd: ["/home/anand-r-m/.local/bin/toggle-menu", "/home/anand-r-m/.local/bin/wallpaper-pick"] }
        ]
        Rectangle {
          required property var modelData
          width: (parent.width - 16) / 3; height: 34; radius: 17
          color: hover.containsMouse ? Colors.primary : Colors.occupied
          BarText {
            anchors.centerIn: parent
            text: modelData.label
            font.pixelSize: 12
            color: hover.containsMouse ? Colors.primaryText : Colors.text
          }
          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: { panel.visible = false; Quickshell.execDetached(modelData.cmd) }
          }
        }
      }
    }
  }
}
