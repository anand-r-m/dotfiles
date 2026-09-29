import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Variants {
  model: Quickshell.screens

  PanelWindow {
    id: dock
    required property var modelData
    screen: modelData

    // Apps that are always in the dock (desktop file names)
    property var pinned: ["brave-browser", "kitty", "thunar"]

    property bool shown: false
    property var apps: {
      const list = pinned.slice()
      for (const t of ToplevelManager.toplevels.values) {
        const id = (t.appId || "").toLowerCase()
        if (id && !list.some(p => p.toLowerCase() === id)) list.push(id)
      }
      return list
    }

    anchors { bottom: true; left: true; right: true }
    implicitHeight: 90
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "dock"
    color: "transparent"

    // Only this area catches the mouse; everything else passes through to your windows
    mask: Region { item: hotzone }

    Item {
      id: hotzone
      anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
      width: dock.shown ? body.width + 24 : parent.width
      height: dock.shown ? body.height + 16 : 8

      HoverHandler {
        onHoveredChanged: {
          if (hovered) { dock.shown = true; hideTimer.stop() }
          else hideTimer.restart()
        }
      }
    }

    Timer { id: hideTimer; interval: 1500; onTriggered: dock.shown = false }

    Rectangle {
      id: body
      anchors.horizontalCenter: parent.horizontalCenter
      y: dock.shown ? parent.height - height - 10 : parent.height + 4
      Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
      height: 62; radius: 20
      width: row.implicitWidth + 24
      color: Colors.pill
      border.color: Colors.border; border.width: 1

      Row {
        id: row
        anchors.centerIn: parent
        spacing: 8

        Repeater {
          model: dock.apps

          Item {
            id: app
            required property string modelData
            property var entry: DesktopEntries.heuristicLookup(modelData)
            property var wins: ToplevelManager.toplevels.values.filter(t => (t.appId || "").toLowerCase() === modelData.toLowerCase())
            property bool focused: wins.some(w => w.activated)
            width: 48; height: 48

            IconImage {
              anchors.centerIn: parent
              implicitSize: ma.containsMouse ? 42 : 36
              Behavior on implicitSize { NumberAnimation { duration: 120 } }
              source: Quickshell.iconPath(app.entry ? app.entry.icon : app.modelData, "application-x-executable")
            }

            Rectangle {
              anchors { bottom: parent.bottom; bottomMargin: -4; horizontalCenter: parent.horizontalCenter }
              visible: app.wins.length > 0
              height: 4; radius: 2
              width: app.focused ? 16 : 5
              color: app.focused ? Colors.primary : Colors.dim
              Behavior on width { NumberAnimation { duration: 150 } }
            }

            MouseArea {
              id: ma
              anchors.fill: parent
              hoverEnabled: true
              acceptedButtons: Qt.LeftButton | Qt.MiddleButton
              onClicked: m => {
                if (m.button === Qt.MiddleButton || app.wins.length === 0) {
                  if (app.entry) app.entry.execute()
                  return
                }
                if (app.focused && app.wins.length > 1) {
                  const i = app.wins.findIndex(w => w.activated)
                  app.wins[(i + 1) % app.wins.length].activate()
                } else {
                  app.wins[0].activate()
                }
              }
            }
          }
        }
      }
    }
  }
}
