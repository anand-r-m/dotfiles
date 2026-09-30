import QtQuick
import Quickshell

Pill {
  BarText {
    text: "\uf011"
    color: Colors.accent
    font.pixelSize: 14
    MouseArea {
      anchors.fill: parent
      onClicked: Quickshell.execDetached(["qs", "ipc", "call", "power", "toggle"])
    }
  }
}
