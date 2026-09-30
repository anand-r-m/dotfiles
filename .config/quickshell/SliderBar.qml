import QtQuick

Item {
  id: s
  property real value: 0
  property bool dimmed: false
  signal moved(real v)
  implicitWidth: 200
  height: 20

  function clamp(v) { return Math.max(0, Math.min(1, v)) }

  Rectangle {
    id: track
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width; height: 8; radius: 4
    color: Colors.occupied
    Rectangle {
      width: track.width * s.value; height: parent.height; radius: 4
      color: s.dimmed ? Colors.dim : Colors.primary
    }
  }
  Rectangle {
    width: 18; height: 18; radius: 9
    anchors.verticalCenter: parent.verticalCenter
    x: track.width * s.value - width / 2
    color: Colors.primaryText
    border.color: s.dimmed ? Colors.dim : Colors.primary; border.width: 3
  }
  MouseArea {
    anchors.fill: parent
    onPressed: m => s.moved(s.clamp(m.x / s.width))
    onPositionChanged: m => s.moved(s.clamp(m.x / s.width))
    onWheel: w => s.moved(s.clamp(s.value + (w.angleDelta.y > 0 ? 0.05 : -0.05)))
  }
}
