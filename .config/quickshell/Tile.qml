import QtQuick

Rectangle {
  id: t
  property string icon
  property string label
  property bool active: false
  signal clicked()
  width: 140; height: 60; radius: 16
  color: active ? Colors.primary : Colors.occupied
  Behavior on color { ColorAnimation { duration: 150 } }

  Row {
    anchors { left: parent.left; leftMargin: 16; verticalCenter: parent.verticalCenter }
    spacing: 12
    BarText {
      anchors.verticalCenter: parent.verticalCenter
      text: t.icon
      font.pixelSize: 16
      color: t.active ? Colors.primaryText : Colors.text
    }
    Column {
      anchors.verticalCenter: parent.verticalCenter
      BarText { text: t.label; font.bold: true; color: t.active ? Colors.primaryText : Colors.text }
      BarText { text: t.active ? "On" : "Off"; font.pixelSize: 11; color: t.active ? Colors.primaryText : Colors.dim }
    }
  }
  MouseArea { anchors.fill: parent; onClicked: t.clicked() }
}
