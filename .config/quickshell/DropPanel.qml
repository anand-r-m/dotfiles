import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
  id: win
  property Item anchorItem
  property real panelWidth: 320
  property real anchorX: 0
  property bool wantsKeyboard: false
  default property alias content: inner.data

  function toggle() {
    if (!visible && anchorItem) anchorX = anchorItem.mapToItem(null, anchorItem.width / 2, 0).x
    visible = !visible
  }

  visible: false
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus: wantsKeyboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
  color: "transparent"

  // Click anywhere outside the panel to close
  MouseArea { anchors.fill: parent; onClicked: win.visible = false }

  Rectangle {
    id: panel
    width: win.panelWidth
    height: inner.implicitHeight + 36
    x: Math.max(12, Math.min(win.width - width - 12, win.anchorX - width / 2))
    y: 50
    radius: 18
    color: Colors.pill
    border.color: Colors.border; border.width: 1

    // Clicks inside the panel don't close it
    MouseArea { anchors.fill: parent }

    Column {
      id: inner
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 18 }
      spacing: 14
    }
  }
}
