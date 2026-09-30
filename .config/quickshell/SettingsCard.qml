import QtQuick

Rectangle {
  property string title: ""
  default property alias content: col.data
  width: parent ? parent.width : 600
  implicitHeight: col.implicitHeight + 40
  radius: 16
  color: Qt.rgba(1, 1, 1, 0.04)
  border.color: Colors.border; border.width: 1

  Column {
    id: col
    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }
    spacing: 14
    BarText { visible: title !== ""; text: title; font.bold: true; color: Colors.dim; font.pixelSize: 12 }
  }
}
