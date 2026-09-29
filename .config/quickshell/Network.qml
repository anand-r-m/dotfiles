import QtQuick
import Quickshell
import Quickshell.Io

BarText {
  id: root
  property string ssid: ""
  property bool radioOn: true
  property var networks: []
  property var saved: []
  property string pwFor: ""
  property string busy: ""
  property string error: ""

  text: "\uf1eb  " + (ssid !== "" ? ssid : (radioOn ? "offline" : "off"))
  color: ssid !== "" ? Colors.text : Colors.dim

  function refresh(rescan) {
    scan.command = ["nmcli", "-t", "-e", "no", "-f", "IN-USE,SIGNAL,SECURITY,SSID",
                    "dev", "wifi", "list", "--rescan", rescan ? "yes" : "no"]
    scan.running = true
    savedProc.running = true
    radioProc.running = true
  }

  function run(cmd, target) {
    root.busy = target
    root.error = ""
    action.command = cmd
    action.running = true
  }

  function choose(n) {
    if (n.inUse) run(["nmcli", "con", "down", "id", n.ssid], n.ssid)
    else if (root.saved.includes(n.ssid)) run(["nmcli", "con", "up", "id", n.ssid], n.ssid)
    else if (!n.secure) run(["nmcli", "dev", "wifi", "connect", n.ssid], n.ssid)
    else { root.pwFor = n.ssid; root.error = "" }
  }

  Process {
    id: scan
    stdout: StdioCollector {
      onStreamFinished: {
        const seen = {}
        const list = []
        for (const line of this.text.split("\n")) {
          if (!line) continue
          const parts = line.split(":")
          const name = parts.slice(3).join(":")
          if (!name) continue
          const inUse = parts[0] === "*"
          const signal = Number(parts[1])
          const secure = parts[2] !== "" && parts[2] !== "--"
          if (seen[name]) {
            if (inUse) seen[name].inUse = true
            if (signal > seen[name].signal) seen[name].signal = signal
            continue
          }
          seen[name] = { ssid: name, signal: signal, secure: secure, inUse: inUse }
          list.push(seen[name])
        }
        list.sort((a, b) => (b.inUse - a.inUse) || (b.signal - a.signal))
        root.networks = list
        const cur = list.find(n => n.inUse)
        root.ssid = cur ? cur.ssid : ""
      }
    }
  }

  Process {
    id: savedProc
    command: ["nmcli", "-t", "-f", "NAME", "con", "show"]
    stdout: StdioCollector { onStreamFinished: root.saved = this.text.split("\n").filter(s => s) }
  }

  Process {
    id: radioProc
    command: ["nmcli", "radio", "wifi"]
    stdout: StdioCollector { onStreamFinished: root.radioOn = this.text.trim() === "enabled" }
  }

  Process {
    id: action
    onExited: (code, status) => {
      if (code !== 0 && root.busy !== "") root.error = "Couldn't connect to " + root.busy + ". Check the password."
      else if (code === 0) root.pwFor = ""
      root.busy = ""
      root.refresh(false)
    }
  }

  Timer {
    interval: 10000; running: true; repeat: true; triggeredOnStart: true
    onTriggered: root.refresh(false)
  }

  MouseArea {
    anchors.fill: parent
    onClicked: { if (!panel.visible) root.refresh(true); panel.toggle() }
  }

  DropPanel {
    id: panel
    anchorItem: root
    panelWidth: 360
    wantsKeyboard: true
    onVisibleChanged: if (!visible) { root.pwFor = ""; root.error = "" }

    // Header with on/off switch
    Item {
      width: parent.width; height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "Wi-Fi"; font.bold: true }
      Rectangle {
        anchors { right: parent.right; verticalCenter: parent.verticalCenter }
        width: 46; height: 26; radius: 13
        color: root.radioOn ? Colors.primary : Colors.occupied
        Behavior on color { ColorAnimation { duration: 150 } }
        Rectangle {
          width: 20; height: 20; radius: 10
          anchors.verticalCenter: parent.verticalCenter
          x: root.radioOn ? parent.width - width - 3 : 3
          color: root.radioOn ? Colors.primaryText : Colors.dim
          Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
        }
        MouseArea {
          anchors.fill: parent
          onClicked: { root.radioOn = !root.radioOn; root.run(["nmcli", "radio", "wifi", root.radioOn ? "on" : "off"], "") }
        }
      }
    }

    // Network list
    Flickable {
      visible: root.radioOn
      width: parent.width
      height: Math.min(list.implicitHeight, 320)
      contentHeight: list.implicitHeight
      clip: true

      Column {
        id: list
        width: parent.width
        spacing: 4

        Repeater {
          model: root.networks

          Column {
            required property var modelData
            width: list.width
            spacing: 6

            Rectangle {
              width: parent.width; height: 48; radius: 12
              color: modelData.inUse ? Colors.occupied : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

              Column {
                anchors { left: parent.left; leftMargin: 12; verticalCenter: parent.verticalCenter }
                spacing: 2
                BarText {
                  text: modelData.ssid
                  font.bold: modelData.inUse
                  color: modelData.inUse ? Colors.primary : Colors.text
                }
                BarText {
                  font.pixelSize: 11
                  color: Colors.dim
                  text: root.busy === modelData.ssid ? "Working…"
                      : modelData.inUse ? "Connected"
                      : root.saved.includes(modelData.ssid) ? "Saved"
                      : modelData.secure ? "Secured" : "Open"
                }
              }

              BarText {
                anchors { right: parent.right; rightMargin: 12; verticalCenter: parent.verticalCenter }
                property int bars: modelData.signal > 75 ? 4 : modelData.signal > 50 ? 3 : modelData.signal > 25 ? 2 : 1
                text: (modelData.secure && !root.saved.includes(modelData.ssid) ? "\uf023  " : "") + "▂▄▆█".slice(0, bars)
                color: Colors.accent
              }

              MouseArea {
                id: hover
                anchors.fill: parent
                hoverEnabled: true
                onClicked: root.choose(modelData)
              }
            }

            // Password field for new secured networks
            Rectangle {
              visible: root.pwFor === modelData.ssid
              width: parent.width; height: 38; radius: 19
              color: Colors.occupied
              border.color: Colors.primary; border.width: 1

              TextInput {
                id: pw
                anchors { left: parent.left; right: go.left; leftMargin: 16; rightMargin: 8; verticalCenter: parent.verticalCenter }
                echoMode: TextInput.Password
                color: Colors.text
                font { family: "JetBrainsMono Nerd Font"; pixelSize: 13 }
                clip: true
                onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
                onAccepted: root.run(["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", text], modelData.ssid)
                BarText {
                  visible: pw.text === ""
                  text: "Password"
                  color: Colors.dim
                }
              }

              Rectangle {
                id: go
                anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                width: 80; height: 30; radius: 15
                color: Colors.primary
                BarText { anchors.centerIn: parent; text: "Connect"; color: Colors.primaryText; font.pixelSize: 12 }
                MouseArea {
                  anchors.fill: parent
                  onClicked: root.run(["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", pw.text], modelData.ssid)
                }
              }
            }
          }
        }
      }
    }

    BarText {
      visible: root.error !== ""
      width: parent.width
      wrapMode: Text.WordWrap
      text: root.error
      color: Colors.accent
      font.pixelSize: 12
    }

    // Rescan button
    Rectangle {
      visible: root.radioOn
      width: parent.width; height: 34; radius: 17
      color: Colors.occupied
      BarText { anchors.centerIn: parent; text: "Rescan" }
      MouseArea { anchors.fill: parent; onClicked: root.refresh(true) }
    }
  }
}
