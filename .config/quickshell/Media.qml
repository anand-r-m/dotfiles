import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Pill {
  id: root
  property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null
  visible: player !== null && (player.trackTitle ?? "") !== ""

  BarText {
    id: label
    text: (root.player?.isPlaying ? "\uf04b  " : "\uf04c  ") + (root.player?.trackTitle ?? "")
    color: Colors.primary
    width: Math.min(implicitWidth, 220)
    elide: Text.ElideRight
    MouseArea { anchors.fill: parent; onClicked: panel.toggle() }
  }

  Timer {
    interval: 1000
    running: panel.visible && (root.player?.isPlaying ?? false)
    repeat: true
    onTriggered: root.player.positionChanged()
  }

  DropPanel {
    id: panel
    anchorItem: label
    panelWidth: 340

    Row {
      width: parent.width
      spacing: 14
      Rectangle {
        width: 72; height: 72; radius: 12
        color: Colors.occupied
        clip: true
        Image {
          anchors.fill: parent
          source: root.player?.trackArtUrl ?? ""
          fillMode: Image.PreserveAspectCrop
          visible: source != ""
        }
      }
      Column {
        width: parent.width - 86
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        BarText { width: parent.width; elide: Text.ElideRight; text: root.player?.trackTitle ?? ""; font.bold: true }
        BarText { width: parent.width; elide: Text.ElideRight; text: root.player?.trackArtist ?? ""; color: Colors.dim; font.pixelSize: 12 }
        BarText { width: parent.width; elide: Text.ElideRight; text: root.player?.identity ?? ""; color: Colors.accent; font.pixelSize: 11 }
      }
    }

    // Progress bar
    Rectangle {
      width: parent.width; height: 6; radius: 3
      color: Colors.occupied
      visible: (root.player?.length ?? 0) > 0
      Rectangle {
        height: parent.height; radius: 3
        color: Colors.primary
        width: parent.width * Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1))
      }
    }

    // Controls
    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 18
      Repeater {
        model: [
          { icon: "\uf048", act: () => root.player.previous() },
          { icon: "playpause", act: () => root.player.togglePlaying() },
          { icon: "\uf051", act: () => root.player.next() }
        ]
        Rectangle {
          required property var modelData
          property bool main: modelData.icon === "playpause"
          width: main ? 48 : 38; height: width; radius: width / 2
          color: main ? Colors.primary : Colors.occupied
          BarText {
            anchors.centerIn: parent
            text: parent.main ? (root.player?.isPlaying ? "\uf04c" : "\uf04b") : modelData.icon
            color: parent.main ? Colors.primaryText : Colors.text
            font.pixelSize: parent.main ? 16 : 13
          }
          MouseArea { anchors.fill: parent; onClicked: if (root.player) modelData.act() }
        }
      }
    }
  }
}
