import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18
  property var sink: Pipewire.defaultAudioSink
  property var source: Pipewire.defaultAudioSource

  PwObjectTracker { objects: [page.sink, page.source] }

  BarText { text: "Sound"; font { pixelSize: 24; bold: true } }

  SettingsCard {
    title: "OUTPUT"
    Item {
      width: parent.width; height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "\uf028  Volume" }
      BarText {
        anchors { right: muteOut.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
        text: Math.round((page.sink?.audio?.volume ?? 0) * 100) + "%"
        color: Colors.primary; font.bold: true
      }
      ToggleSwitch {
        id: muteOut
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        checked: !(page.sink?.audio?.muted ?? false)
        onToggled: if (page.sink) page.sink.audio.muted = !page.sink.audio.muted
      }
    }
    SliderBar {
      width: parent.width
      value: page.sink?.audio?.volume ?? 0
      dimmed: page.sink?.audio?.muted ?? false
      onMoved: v => { if (page.sink) page.sink.audio.volume = v }
    }
    Repeater {
      model: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
      Rectangle {
        required property var modelData
        property bool current: modelData === page.sink
        width: parent.width; height: 40; radius: 10
        color: current ? Colors.occupied : (h1.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
        BarText {
          anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
          text: modelData.description || modelData.nickname || modelData.name
          color: current ? Colors.primary : Colors.text; font.bold: current
        }
        BarText { anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
visible: current; text: "\uf00c"; color: Colors.primary }
        MouseArea { id: h1; anchors.fill: parent; hoverEnabled: true; onClicked: Pipewire.preferredDefaultAudioSink = modelData }
      }
    }
  }

  SettingsCard {
    title: "INPUT"
    Item {
      width: parent.width; height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "\uf130  Microphone" }
      BarText {
        anchors { right: muteIn.left; rightMargin: 14; verticalCenter: parent.verticalCenter }
        text: Math.round((page.source?.audio?.volume ?? 0) * 100) + "%"
        color: Colors.primary; font.bold: true
      }
      ToggleSwitch {
        id: muteIn
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        checked: !(page.source?.audio?.muted ?? false)
        onToggled: if (page.source) page.source.audio.muted = !page.source.audio.muted
      }
    }
    SliderBar {
      width: parent.width
      value: page.source?.audio?.volume ?? 0
      dimmed: page.source?.audio?.muted ?? false
      onMoved: v => { if (page.source) page.source.audio.volume = v }
    }
    Repeater {
      model: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
      Rectangle {
        required property var modelData
        property bool current: modelData === page.source
        width: parent.width; height: 40; radius: 10
        color: current ? Colors.occupied : (h2.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
        BarText {
          anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
          text: modelData.description || modelData.nickname || modelData.name
          color: current ? Colors.primary : Colors.text; font.bold: current
        }
        BarText { anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
visible: current; text: "\uf00c"; color: Colors.primary }
        MouseArea { id: h2; anchors.fill: parent; hoverEnabled: true; onClicked: Pipewire.preferredDefaultAudioSource = modelData }
      }
    }
  }

  Rectangle {
    width: 220; height: 36; radius: 18
    color: adv.containsMouse ? Colors.primary : Colors.occupied
    BarText { anchors.centerIn: parent; text: "Per-app volume (advanced)"; font.pixelSize: 12; color: adv.containsMouse ? Colors.primaryText : Colors.text }
    MouseArea { id: adv; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["pavucontrol"]) }
  }
}
