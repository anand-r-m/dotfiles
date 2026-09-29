import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

BarText {
  id: root
  property var sink: Pipewire.defaultAudioSink
  property bool muted: sink?.audio?.muted ?? false
  property real level: sink?.audio?.volume ?? 0
  property int vol: Math.round(level * 100)
  text: (muted ? "\uf026  " : (vol < 50 ? "\uf027  " : "\uf028  ")) + vol + "%"
  color: muted ? Colors.dim : Colors.text

  PwObjectTracker { objects: [sink] }

  function setVol(v) { if (sink) sink.audio.volume = Math.max(0, Math.min(1, v)) }

  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: m => {
      if (m.button === Qt.RightButton) { if (sink) sink.audio.muted = !sink.audio.muted }
      else panel.toggle()
    }
    onWheel: w => root.setVol(root.level + (w.angleDelta.y > 0 ? 0.05 : -0.05))
  }

  DropPanel {
    id: panel
    anchorItem: root
    panelWidth: 300

    // Header
    Item {
      width: parent.width; height: 18
      BarText { anchors.left: parent.left; text: "Volume"; font.bold: true }
      BarText { anchors.right: parent.right; text: root.muted ? "muted" : root.vol + "%"; color: Colors.primary; font.bold: true }
    }

    // Slider
    Item {
      id: slider
      width: parent.width; height: 20
      Rectangle {
        id: track
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 8; radius: 4
        color: Colors.occupied
        Rectangle {
          width: track.width * root.level; height: parent.height; radius: 4
          color: root.muted ? Colors.dim : Colors.primary
        }
      }
      Rectangle {
        width: 18; height: 18; radius: 9
        anchors.verticalCenter: parent.verticalCenter
        x: track.width * root.level - width / 2
        color: Colors.primaryText
        border.color: root.muted ? Colors.dim : Colors.primary; border.width: 3
      }
      MouseArea {
        anchors.fill: parent
        onPressed: m => root.setVol(m.x / slider.width)
        onPositionChanged: m => root.setVol(m.x / slider.width)
        onWheel: w => root.setVol(root.level + (w.angleDelta.y > 0 ? 0.05 : -0.05))
      }
    }

    // Buttons
    Row {
      spacing: 10
      Rectangle {
        width: 90; height: 30; radius: 15
        color: root.muted ? Colors.primary : Colors.occupied
        BarText { anchors.centerIn: parent; text: root.muted ? "Unmute" : "Mute"; color: root.muted ? Colors.primaryText : Colors.text }
        MouseArea { anchors.fill: parent; onClicked: if (root.sink) root.sink.audio.muted = !root.sink.audio.muted }
      }
      Rectangle {
        width: 110; height: 30; radius: 15
        color: Colors.occupied
        BarText { anchors.centerIn: parent; text: "Outputs \uf107" }
        MouseArea {
          anchors.fill: parent
          onClicked: { panel.visible = false; Quickshell.execDetached(["/home/anand-r-m/.local/bin/volume-menu"]) }
        }
      }
    }
  }
}
