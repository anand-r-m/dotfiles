import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18
  property string home: Quickshell.env("HOME")
  property string current: ""
  property bool dark: true

  FileView {
    path: page.home + "/.cache/current-wallpaper"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: page.current = text().trim()
  }

  FileView {
    path: page.home + "/.cache/theme-mode"
    watchChanges: true
    onFileChanged: reload()
    onLoaded: page.dark = text().trim() !== "light"
  }

  FolderListModel {
    id: walls
    folder: "file://" + page.home + "/Pictures/Wallpapers"
    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG"]
    showDirs: false
  }

  BarText { text: "Appearance"; font.pixelSize: 24; font.bold: true }

  SettingsCard {
    title: "THEME"
    Item {
      width: parent.width
      height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "\uf186  Dark mode" }
      ToggleSwitch {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: page.dark
        onToggled: {
          page.dark = !page.dark
          Quickshell.execDetached(["sh", "-c", "echo " + (page.dark ? "dark" : "light") + " > ~/.cache/theme-mode && ~/.local/bin/wallpaper-set"])
        }
      }
    }
    BarText {
      text: "Colors are generated from your wallpaper automatically."
      color: Colors.dim
      font.pixelSize: 12
    }
  }

  SettingsCard {
    title: "WALLPAPER"

    Grid {
      id: grid
      width: parent.width
      columns: 3
      spacing: 12

      Repeater {
        model: walls

        Rectangle {
          required property string filePath
          required property string fileName
          property bool isCurrent: filePath === page.current
          width: (grid.width - 24) / 3
          height: width * 0.62
          radius: 14
          color: Colors.occupied
          border.color: isCurrent ? Colors.primary : (hover.containsMouse ? Colors.accent : "transparent")
          border.width: isCurrent ? 3 : 2
          scale: hover.containsMouse ? 1.03 : 1
          Behavior on scale { NumberAnimation { duration: 120 } }

          Image {
            anchors.fill: parent
            anchors.margins: 4
            source: "file://" + filePath
            sourceSize.width: 360
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
          }

          Rectangle {
            visible: isCurrent
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: 10
            width: 26
            height: 26
            radius: 13
            color: Colors.primary
            BarText { anchors.centerIn: parent; text: "\uf00c"; color: Colors.primaryText; font.pixelSize: 12 }
          }

          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: Quickshell.execDetached([page.home + "/.local/bin/wallpaper-set", filePath])
          }
        }
      }
    }

    Row {
      spacing: 10
      Rectangle {
        width: 190
        height: 34
        radius: 17
        color: folderHover.containsMouse ? Colors.primary : Qt.rgba(1, 1, 1, 0.06)
        BarText { anchors.centerIn: parent; text: "\uf07c  Open folder"; color: folderHover.containsMouse ? Colors.primaryText : Colors.text }
        MouseArea { id: folderHover; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["thunar", page.home + "/Pictures/Wallpapers"]) }
      }
      Rectangle {
        width: 190
        height: 34
        radius: 17
        color: gtkHover.containsMouse ? Colors.primary : Qt.rgba(1, 1, 1, 0.06)
        BarText { anchors.centerIn: parent; text: "\uf1fc  App themes"; color: gtkHover.containsMouse ? Colors.primaryText : Colors.text }
        MouseArea { id: gtkHover; anchors.fill: parent; hoverEnabled: true; onClicked: Quickshell.execDetached(["nwg-look"]) }
      }
    }
  }
}
