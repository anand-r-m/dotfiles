import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: win
  visible: false
  property string page: "Display"
  property var pages: [
    { id: "Wifi",       icon: "\uf1eb", label: "Wi-Fi" },
    { id: "Bluetooth",  icon: "\uf293", label: "Bluetooth" },
    { id: "Sound",      icon: "\uf028", label: "Sound" },
    { id: "Display",    icon: "\uf108", label: "Display" },
    { id: "Appearance", icon: "\uf1fc", label: "Appearance" },
    { id: "Keys",       icon: "\uf11c", label: "Shortcuts" },
    { id: "About",      icon: "\uf05a", label: "About" }
  ]

  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "settings"
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  color: "transparent"

  IpcHandler {
    target: "settings"
    function toggle(): void { win.visible = !win.visible }
    function open(p: string): void { win.page = p; win.visible = true }
  }

  onVisibleChanged: if (visible) keys.forceActiveFocus()

  Rectangle {
    anchors.fill: parent
    color: Qt.rgba(0, 0, 0, 0.55)
    MouseArea { anchors.fill: parent; onClicked: win.visible = false }
  }

  Item { id: keys; focus: true; Keys.onEscapePressed: win.visible = false }

  Rectangle {
    id: card
    anchors.centerIn: parent
    width: Math.min(980, parent.width - 80)
    height: Math.min(660, parent.height - 80)
    radius: 24
    color: Colors.pill
    border.color: Colors.border; border.width: 1
    MouseArea { anchors.fill: parent }

    // Sidebar
    Column {
      id: sidebar
      anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 20 }
      width: 210
      spacing: 6
      BarText { text: "Settings"; font.pixelSize: 22; font.bold: true; bottomPadding: 14; leftPadding: 8 }
      Repeater {
        model: win.pages
        Rectangle {
          required property var modelData
          property bool current: win.page === modelData.id
          width: sidebar.width; height: 42; radius: 12
          color: current ? Colors.primary : (hover.containsMouse ? Colors.occupied : "transparent")
          Behavior on color { ColorAnimation { duration: 120 } }
          Row {
            anchors { left: parent.left; leftMargin: 14; verticalCenter: parent.verticalCenter }
            spacing: 14
            BarText { width: 18; horizontalAlignment: Text.AlignHCenter; text: modelData.icon; color: current ? Colors.primaryText : Colors.accent }
            BarText { text: modelData.label; font.bold: current; color: current ? Colors.primaryText : Colors.text }
          }
          MouseArea { id: hover; anchors.fill: parent; hoverEnabled: true; onClicked: win.page = modelData.id }
        }
      }
    }

    Rectangle {
      id: divider
      anchors { left: sidebar.right; leftMargin: 20; top: parent.top; bottom: parent.bottom; topMargin: 20; bottomMargin: 20 }
      width: 1
      color: Colors.border
    }

    // Close button
    Rectangle {
      anchors { top: parent.top; right: parent.right; margins: 16 }
      width: 32; height: 32; radius: 16
      color: closeHover.containsMouse ? Colors.primary : Colors.occupied
      BarText { anchors.centerIn: parent; text: "\uf00d"; color: closeHover.containsMouse ? Colors.primaryText : Colors.text }
      MouseArea { id: closeHover; anchors.fill: parent; hoverEnabled: true; onClicked: win.visible = false }
    }

    // Page content
    Flickable {
      anchors { left: divider.right; right: parent.right; top: parent.top; bottom: parent.bottom; leftMargin: 28; rightMargin: 60; topMargin: 28; bottomMargin: 28 }
      contentHeight: loader.item ? loader.item.implicitHeight : 0
      clip: true
      Loader {
        id: loader
        width: parent.width
        source: "Settings" + win.page + ".qml"
      }
    }
  }
}
