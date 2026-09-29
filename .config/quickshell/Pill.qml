import QtQuick

Rectangle {
  default property alias content: row.data
  property alias spacing: row.spacing
  height: 30; radius: 15
  width: row.implicitWidth + 28
  color: Colors.pill; border.color: Colors.border; border.width: 1
  Row { id: row; anchors.centerIn: parent; spacing: 14 }
}
