//@ pragma IconTheme Papirus-Dark
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import QtQuick

ShellRoot {
  Settings {}
  PowerScreen {}
  Dock {}
  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: bar
      required property var modelData
      screen: modelData
      anchors { top: true; left: true; right: true }
      implicitHeight: 44
      color: "transparent"

      SystemClock { id: clock; precision: SystemClock.Minutes }

      // LEFT: date + stats
      Row {
        anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 8
        Pill {
          BarText { text: Qt.formatDateTime(clock.date, "ddd, dd MMM"); font.bold: true }
        }
        Pill { Stats {} }
        Media {}
      }

      // CENTER: workspaces
      Pill {
        anchors.centerIn: parent
        spacing: 6
        Repeater {
          model: 6
          Rectangle {
            required property int index
            property int wsId: index + 1
            property bool isActive: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId
            property bool isUsed: Hyprland.workspaces.values.some(w => w.id === wsId)
            width: isActive ? 34 : 20; height: 20; radius: 10
            color: isActive ? Colors.primary : (isUsed ? Colors.occupied : "transparent")
            Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
            Text {
              anchors.centerIn: parent
              text: wsId
              color: isActive ? Colors.primaryText : Colors.dim
              font { family: "JetBrainsMono Nerd Font"; pixelSize: 11; bold: isActive }
            }
            MouseArea {
              anchors.fill: parent
              onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + wsId + " })")
            }
          }
        }
      }

      // RIGHT: tray + status + power
      Row {
        anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
        spacing: 8

        Pill {
          visible: SystemTray.items.values.length > 0
          spacing: 10
          Repeater {
            model: SystemTray.items
            IconImage {
              required property var modelData
              source: modelData.icon
              implicitSize: 16
              MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: m => {
                  if (m.button === Qt.RightButton && modelData.hasMenu) {
                    const p = parent.mapToItem(null, 0, parent.height + 8)
                    modelData.display(bar, p.x, p.y)
                  } else {
                    modelData.activate()
                  }
                }
              }
            }
          }
        }

        Pill {
          Network {}
          BtStatus {}
          Volume {}
          BarText {
            property real p: UPower.displayDevice.percentage
            property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging
            text: (charging ? "\uf0e7  " : "\uf240  ") + Math.round(p <= 1 ? p * 100 : p) + "%"
            color: Colors.accent
          }
          BarText {
            text: Qt.formatDateTime(clock.date, "hh:mm")
            color: Colors.primary
            font.bold: true
          }
        }

        ControlCenter {}
        PowerButton {}
      }
    }
  }
}
