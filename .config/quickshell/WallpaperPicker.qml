import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
  id: win
  visible: false
  property string home: Quickshell.env("HOME")

  // Size of the selected (center) slice
  property real baseW: 150
  property real baseH: 380

  property string previewPath: (walls.count > 0 && list.currentIndex >= 0) ? walls.get(list.currentIndex, "filePath") : ""
  onPreviewPathChanged: if (visible) bg.show(previewPath)

  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "wallpaper-picker"
  WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
  color: "black"

  FolderListModel {
    id: walls
    folder: "file://" + win.home + "/Pictures/Wallpapers"
    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG"]
    showDirs: false
  }

  FileView { id: cur; path: win.home + "/.cache/current-wallpaper"; blockLoading: true }

  function open() {
    cur.reload()
    const c = cur.text().trim()
    let idx = 0
    for (let i = 0; i < walls.count; i++) {
      if (walls.get(i, "filePath") === c) idx = i
    }
    win.visible = true
    list.currentIndex = idx
    list.positionViewAtIndex(idx, ListView.Center)
    bg.show(walls.get(idx, "filePath"))
    list.forceActiveFocus()
  }

  function apply() {
    const p = walls.get(list.currentIndex, "filePath")
    win.visible = false
    if (p) Quickshell.execDetached([win.home + "/.local/bin/wallpaper-set", p])
  }

  IpcHandler {
    target: "wallpaper"
    function toggle(): void {
      if (win.visible) win.visible = false
      else win.open()
    }
  }

  // Full-screen live preview with crossfade
  Item {
    id: bg
    anchors.fill: parent
    property bool showA: true
    property var pending: null

    function show(p) {
      if (!p) return
      const target = showA ? imgB : imgA
      pending = target
      target.source = "file://" + p
      if (target.status === Image.Ready) flip()
    }
    function flip() { showA = (pending === imgA) }

    Image {
      id: imgA
      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
      sourceSize.width: win.width
      asynchronous: true
      opacity: bg.showA ? 1 : 0
      Behavior on opacity { NumberAnimation { duration: 350 } }
      onStatusChanged: if (status === Image.Ready && bg.pending === imgA) bg.flip()
    }
    Image {
      id: imgB
      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
      sourceSize.width: win.width
      asynchronous: true
      opacity: bg.showA ? 0 : 1
      Behavior on opacity { NumberAnimation { duration: 350 } }
      onStatusChanged: if (status === Image.Ready && bg.pending === imgB) bg.flip()
    }
  }

  // Click empty space to close
  MouseArea { anchors.fill: parent; onClicked: win.visible = false }

  ListView {
    id: list
    anchors.centerIn: parent
    width: parent.width
    height: win.baseH + 40
    orientation: ListView.Horizontal
    spacing: 28
    model: walls
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: width / 2 - win.baseW / 2
    preferredHighlightEnd: width / 2 + win.baseW / 2
    highlightMoveDuration: 260
    keyNavigationEnabled: true
    Keys.onReturnPressed: win.apply()
    Keys.onEnterPressed: win.apply()
    Keys.onEscapePressed: win.visible = false

    delegate: Item {
      id: item
      required property string filePath
      required property int index
      property int dist: Math.abs(index - list.currentIndex)
      property real f: Math.max(0.32, 1 - dist * 0.13)
      width: win.baseW * f
      height: list.height
      Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

      Rectangle {
        anchors.centerIn: parent
        width: parent.width
        height: win.baseH * item.f
        radius: 6
        color: "black"
        clip: true
        Behavior on height { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

        Image {
          anchors.fill: parent
          source: "file://" + item.filePath
          sourceSize.height: 420
          fillMode: Image.PreserveAspectCrop
          asynchronous: true
        }
      }

      MouseArea {
        anchors.fill: parent
        onClicked: {
          if (list.currentIndex === item.index) win.apply()
          else list.currentIndex = item.index
        }
      }
    }
  }
}
