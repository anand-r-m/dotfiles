import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: win
  visible: false
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "powerscreen"
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  color: "transparent"

  property var actions: [
    { label: "Lock",      icon: "\uf023", key: "l", cmd: ["loginctl", "lock-session"] },
    { label: "Log out",   icon: "\uf08b", key: "e", cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
    { label: "Suspend",   icon: "\uf186", key: "s", cmd: ["systemctl", "suspend"] },
    { label: "Reboot",    icon: "\uf01e", key: "r", cmd: ["systemctl", "reboot"] },
    { label: "Windows",   icon: "\uf17a", key: "w", cmd: ["systemctl", "reboot", "--boot-loader-entry=auto-windows"] },
    { label: "Shut down", icon: "\uf011", key: "p", cmd: ["systemctl", "poweroff"] }
  ]

  function run(a) { win.visible = false; Quickshell.execDetached(a.cmd) }

  IpcHandler {
    target: "power"
    function toggle(): void { win.visible = !win.visible }
  }

  onVisibleChanged: if (visible) keys.forceActiveFocus()

  SystemClock { id: clock; precision: SystemClock.Minutes }

  // Dimmed background: click to close
  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.7)
    MouseArea { anchors.fill: parent; onClicked: win.visible = false }
  }

  // Keyboard: Esc closes, letters trigger actions
  Item {
    id: keys
    anchors.fill: parent
    focus: true
    Keys.onPressed: e => {
      if (e.key === Qt.Key_Escape) { win.visible = false; return }
      const a = win.actions.find(x => x.key === e.text.toLowerCase())
      if (a) win.run(a)
    }
  }

  Column {
    anchors.centerIn: parent
    spacing: 48

    Column {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 6
      BarText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "hh:mm")
        color: Colors.primary
        font { pixelSize: 84; bold: true }
      }
      BarText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: Qt.formatDateTime(clock.date, "dddd, dd MMMM")
        color: Colors.text
        font.pixelSize: 18
      }
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 20

      Repeater {
        model: win.actions

        Rectangle {
          required property var modelData
          width: 150; height: 170; radius: 28
          color: hover.containsMouse ? Colors.primary : Colors.pill
          border.color: hover.containsMouse ? Colors.primary : Colors.border
          border.width: 1
          scale: hover.containsMouse ? 1.06 : 1
          Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
          Behavior on color { ColorAnimation { duration: 140 } }

          Column {
            anchors.centerIn: parent
            spacing: 14
            BarText {
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.icon
              font.pixelSize: 42
              color: hover.containsMouse ? Colors.primaryText : Colors.accent
            }
            BarText {
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.label
              font.bold: true
              color: hover.containsMouse ? Colors.primaryText : Colors.text
            }
            BarText {
              anchors.horizontalCenter: parent.horizontalCenter
              text: modelData.key.toUpperCase()
              font.pixelSize: 11
              color: hover.containsMouse ? Colors.primaryText : Colors.dim
            }
          }

          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: win.run(modelData)
          }
        }
      }
    }
  }
}
