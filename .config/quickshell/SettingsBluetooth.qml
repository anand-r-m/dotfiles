import QtQuick
import Quickshell
import Quickshell.Bluetooth

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18
  property var adapter: Bluetooth.defaultAdapter
  property bool on: adapter?.enabled ?? false
  property bool scanning: adapter?.discovering ?? false

  Component.onDestruction: if (adapter) adapter.discovering = false

  BarText { text: "Bluetooth"; font.pixelSize: 24; font.bold: true }

  SettingsCard {
    Item {
      width: parent.width
      height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "\uf293  Bluetooth" }
      ToggleSwitch {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: page.on
        onToggled: if (page.adapter) page.adapter.enabled = !page.on
      }
    }
  }

  SettingsCard {
    title: page.scanning ? "DEVICES  ·  SCANNING…" : "DEVICES"
    visible: page.on

    Repeater {
      model: Bluetooth.devices.values
        .filter(d => d.paired || page.scanning)
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired))

      Rectangle {
        required property var modelData
        width: parent.width
        height: 50
        radius: 12
        color: modelData.connected ? Colors.occupied : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

        Column {
          anchors.left: parent.left
          anchors.leftMargin: 14
          anchors.verticalCenter: parent.verticalCenter
          spacing: 2
          BarText {
            text: modelData.name || modelData.address
            font.bold: modelData.connected
            color: modelData.connected ? Colors.primary : Colors.text
          }
          BarText {
            font.pixelSize: 11
            color: Colors.dim
            text: modelData.state === BluetoothDeviceState.Connecting ? "Connecting…"
                : modelData.pairing ? "Pairing…"
                : modelData.connected ? "Connected" + (modelData.batteryAvailable ? "  ·  battery " + Math.round(modelData.battery * 100) + "%" : "")
                : modelData.paired ? "Paired"
                : "New device"
          }
        }

        BarText {
          anchors.right: parent.right
          anchors.rightMargin: 14
          anchors.verticalCenter: parent.verticalCenter
          font.pixelSize: 12
          font.bold: true
          color: Colors.accent
          text: !modelData.paired ? "Pair" : (modelData.connected ? "Disconnect" : "Connect")
        }

        MouseArea {
          id: hover
          anchors.fill: parent
          hoverEnabled: true
          onClicked: {
            if (!modelData.paired) { modelData.trusted = true; modelData.pair() }
            else modelData.connected = !modelData.connected
          }
        }
      }
    }

    BarText {
      visible: Bluetooth.devices.values.filter(d => d.paired).length === 0 && !page.scanning
      text: "No paired devices yet. Tap Scan to find some."
      color: Colors.dim
      font.pixelSize: 12
    }

    Rectangle {
      width: 200
      height: 34
      radius: 17
      color: page.scanning ? Colors.primary : (scanHover.containsMouse ? Colors.occupied : Qt.rgba(1, 1, 1, 0.06))
      BarText {
        anchors.centerIn: parent
        text: page.scanning ? "Stop scanning" : "\uf002  Scan for devices"
        color: page.scanning ? Colors.primaryText : Colors.text
      }
      MouseArea {
        id: scanHover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: if (page.adapter) page.adapter.discovering = !page.scanning
      }
    }
  }
}
