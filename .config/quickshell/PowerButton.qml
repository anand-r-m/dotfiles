import QtQuick
import Quickshell

Pill {
  id: root
  property string confirm: ""

  BarText {
    id: icon
    text: "\uf011"
    color: Colors.accent
    font.pixelSize: 14
    MouseArea { anchors.fill: parent; onClicked: { root.confirm = ""; panel.toggle() } }
  }

  DropPanel {
    id: panel
    anchorItem: icon
    panelWidth: 280

    BarText { text: "Power"; font.bold: true }

    Column {
      width: parent.width
      spacing: 4

      Repeater {
        model: [
          { label: "Lock",              icon: "\uf023", cmd: ["loginctl", "lock-session"], ask: false },
          { label: "Suspend",           icon: "\uf186", cmd: ["systemctl", "suspend"], ask: false },
          { label: "Log out",           icon: "\uf08b", cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"], ask: true },
          { label: "Reboot",            icon: "\uf01e", cmd: ["systemctl", "reboot"], ask: true },
          { label: "Reboot to Windows", icon: "\uf17a", cmd: ["systemctl", "reboot", "--boot-loader-entry=auto-windows"], ask: true },
          { label: "Shut down",         icon: "\uf011", cmd: ["systemctl", "poweroff"], ask: true }
        ]

        Rectangle {
          required property var modelData
          property bool confirming: root.confirm === modelData.label
          width: parent.width; height: 42; radius: 12
          color: confirming ? Colors.primary : (hover.containsMouse ? Colors.occupied : "transparent")
          Behavior on color { ColorAnimation { duration: 120 } }

          Row {
            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
            spacing: 14
            BarText {
              width: 18
              horizontalAlignment: Text.AlignHCenter
              text: modelData.icon
              color: confirming ? Colors.primaryText : Colors.accent
            }
            BarText {
              text: confirming ? "Click again to confirm" : modelData.label
              color: confirming ? Colors.primaryText : Colors.text
              font.bold: confirming
            }
          }

          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
              if (modelData.ask && !confirming) { root.confirm = modelData.label; return }
              panel.visible = false
              Quickshell.execDetached(modelData.cmd)
            }
          }
        }
      }
    }
  }
}
