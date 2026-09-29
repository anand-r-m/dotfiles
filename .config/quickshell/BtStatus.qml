import QtQuick
import Quickshell
import Quickshell.Bluetooth

BarText {
  id: root
  property var adapter: Bluetooth.defaultAdapter
  property bool on: adapter?.enabled ?? false
  property var connected: Bluetooth.devices.values.filter(d => d.connected)
  text: "\uf293" + (on && connected.length > 0 ? "  " + connected[0].name : "")
  color: on ? (connected.length > 0 ? Colors.primary : Colors.text) : Colors.dim

  MouseArea { anchors.fill: parent; onClicked: panel.toggle() }

  DropPanel {
    id: panel
    anchorItem: root
    panelWidth: 340
    onVisibleChanged: if (!visible && root.adapter) root.adapter.discovering = false

    // Header with on/off switch
    Item {
      width: parent.width; height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "Bluetooth"; font.bold: true }
      Rectangle {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        width: 46; height: 26; radius: 13
        color: root.on ? Colors.primary : Colors.occupied
        Behavior on color { ColorAnimation { duration: 150 } }
        Rectangle {
          width: 20; height: 20; radius: 10
          anchors.verticalCenter: parent.verticalCenter
          x: root.on ? parent.width - width - 3 : 3
          color: root.on ? Colors.primaryText : Colors.dim
          Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
        MouseArea { anchors.fill: parent; onClicked: if (root.adapter) root.adapter.enabled = !root.on }
      }
    }

    // Device list
    Column {
      width: parent.width
      spacing: 4
      visible: root.on

      Repeater {
        model: Bluetooth.devices.values
          .filter(d => d.paired || (root.adapter?.discovering ?? false))
          .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired))

        Rectangle {
          required property var modelData
          width: parent.width; height: 48; radius: 12
          color: modelData.connected ? Colors.occupied : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

          Column {
            anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
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
                  : modelData.connected ? "Connected" + (modelData.batteryAvailable ? "  ·  " + Math.round(modelData.battery * 100) + "%" : "")
                  : modelData.paired ? "Paired"
                  : "New device"
            }
          }

          BarText {
            anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
            font.pixelSize: 11; font.bold: true
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
        visible: Bluetooth.devices.values.filter(d => d.paired).length === 0 && !(root.adapter?.discovering ?? false)
        text: "No paired devices. Tap Scan."
        color: Colors.dim; font.pixelSize: 12
      }
    }

    // Scan button
    Rectangle {
      visible: root.on
      width: parent.width; height: 34; radius: 17
      color: root.adapter?.discovering ? Colors.primary : Colors.occupied
      BarText {
        anchors.centerIn: parent
        text: root.adapter?.discovering ? "Scanning…  (tap to stop)" : "Scan for devices"
        color: root.adapter?.discovering ? Colors.primaryText : Colors.text
      }
      MouseArea {
        anchors.fill: parent
        onClicked: if (root.adapter) root.adapter.discovering = !root.adapter.discovering
      }
    }
  }
}
