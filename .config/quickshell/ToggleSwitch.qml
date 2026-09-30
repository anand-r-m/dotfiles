import QtQuick

Rectangle {
  id: sw
  property bool checked: false
  signal toggled()
  width: 46; height: 26; radius: 13
  color: checked ? Colors.primary : Colors.occupied
  Behavior on color { ColorAnimation { duration: 150 } }
  Rectangle {
    width: 20; height: 20; radius: 10
    anchors.verticalCenter: parent.verticalCenter
    x: sw.checked ? parent.width - width - 3 : 3
    color: sw.checked ? Colors.primaryText : Colors.dim
    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
  }
  MouseArea { anchors.fill: parent; onClicked: sw.toggled() }
}
