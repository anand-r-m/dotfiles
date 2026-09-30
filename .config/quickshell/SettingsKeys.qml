import QtQuick
import Quickshell
import Quickshell.Io

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18

  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.config/hypr/cheatsheet.txt"
    blockLoading: true
  }

  property var entries: file.text().split("\n").filter(l => l.trim() !== "").map(l => {
    const m = l.replace(/\s*::.*$/, "").match(/^(.+?)\s{2,}(.+)$/)
    return m ? { keys: m[1].trim(), desc: m[2].trim() } : { keys: l.trim(), desc: "" }
  })

  BarText { text: "Keyboard shortcuts"; font { pixelSize: 24; bold: true } }
  BarText { text: "Edit ~/.config/hypr/cheatsheet.txt to change this list."; color: Colors.dim; font.pixelSize: 12 }

  SettingsCard {
    Repeater {
      model: page.entries
      Item {
        required property var modelData
        width: parent.width; height: 32
        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: keyText.implicitWidth + 20; height: 26; radius: 8
          color: Colors.occupied
          BarText { id: keyText; anchors.centerIn: parent; text: modelData.keys; color: Colors.primary; font { pixelSize: 12; bold: true } }
        }
        BarText { anchors { left: parent.left; leftMargin: 240; verticalCenter: parent.verticalCenter }
text: modelData.desc }
      }
    }
  }
}
