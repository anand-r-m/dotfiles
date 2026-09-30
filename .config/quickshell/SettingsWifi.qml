import QtQuick
import Quickshell
import Quickshell.Io

Column {
  id: page
  width: parent ? parent.width : 600
  spacing: 18
  property bool radioOn: true
  property var networks: []
  property var saved: []
  property string pwFor: ""
  property string busy: ""
  property string error: ""

  function refresh(rescan) {
    scan.command = ["nmcli", "-t", "-e", "no", "-f", "IN-USE,SIGNAL,SECURITY,SSID",
                    "dev", "wifi", "list", "--rescan", rescan ? "yes" : "no"]
    scan.running = true
    savedProc.running = true
    radioProc.running = true
  }

  function run(cmd, target) {
    page.busy = target
    page.error = ""
    action.command = cmd
    action.running = true
  }

  function choose(n) {
    if (n.inUse) run(["nmcli", "con", "down", "id", n.ssid], n.ssid)
    else if (page.saved.includes(n.ssid)) run(["nmcli", "con", "up", "id", n.ssid], n.ssid)
    else if (!n.secure) run(["nmcli", "dev", "wifi", "connect", n.ssid], n.ssid)
    else { page.pwFor = n.ssid; page.error = "" }
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
        page.networks = list
      }
    }
  }

  Process {
    id: savedProc
    command: ["nmcli", "-t", "-f", "NAME", "con", "show"]
    stdout: StdioCollector { onStreamFinished: page.saved = this.text.split("\n").filter(s => s) }
  }

  Process {
    id: radioProc
    command: ["nmcli", "radio", "wifi"]
    stdout: StdioCollector { onStreamFinished: page.radioOn = this.text.trim() === "enabled" }
  }

  Process {
    id: action
    onExited: (code, status) => {
      if (code !== 0 && page.busy !== "") page.error = "Couldn't connect to " + page.busy + ". Check the password."
      else if (code === 0) page.pwFor = ""
      page.busy = ""
      page.refresh(false)
    }
  }

  Component.onCompleted: refresh(true)

  BarText { text: "Wi-Fi"; font.pixelSize: 24; font.bold: true }

  SettingsCard {
    Item {
      width: parent.width
      height: 26
      BarText { anchors.verticalCenter: parent.verticalCenter; text: "\uf1eb  Wi-Fi" }
      ToggleSwitch {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: page.radioOn
        onToggled: {
          page.radioOn = !page.radioOn
          page.run(["nmcli", "radio", "wifi", page.radioOn ? "on" : "off"], "")
        }
      }
    }
  }

  SettingsCard {
    title: "NETWORKS"
    visible: page.radioOn

    Repeater {
      model: page.networks

      Column {
        required property var modelData
        width: parent.width
        spacing: 6

        Rectangle {
          width: parent.width
          height: 50
          radius: 12
          color: modelData.inUse ? Colors.occupied : (hover.containsMouse ? Qt.rgba(1, 1, 1, 0.05) : "transparent")

          Column {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            BarText {
              text: modelData.ssid
              font.bold: modelData.inUse
              color: modelData.inUse ? Colors.primary : Colors.text
            }
            BarText {
              font.pixelSize: 11
              color: Colors.dim
              text: page.busy === modelData.ssid ? "Working…"
                  : modelData.inUse ? "Connected"
                  : page.saved.includes(modelData.ssid) ? "Saved"
                  : modelData.secure ? "Secured" : "Open"
            }
          }

          BarText {
            anchors.right: parent.right
            anchors.rightMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            property int bars: modelData.signal > 75 ? 4 : modelData.signal > 50 ? 3 : modelData.signal > 25 ? 2 : 1
            text: (modelData.secure && !page.saved.includes(modelData.ssid) ? "\uf023  " : "") + "▂▄▆█".slice(0, bars)
            color: Colors.accent
          }

          MouseArea {
            id: hover
            anchors.fill: parent
            hoverEnabled: true
            onClicked: page.choose(modelData)
          }
        }

        Rectangle {
          visible: page.pwFor === modelData.ssid
          width: parent.width
          height: 40
          radius: 20
          color: Colors.occupied
          border.color: Colors.primary
          border.width: 1

          TextInput {
            id: pw
            anchors.left: parent.left
            anchors.right: go.left
            anchors.leftMargin: 16
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            echoMode: TextInput.Password
            color: Colors.text
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 13
            clip: true
            onVisibleChanged: if (visible) { text = ""; forceActiveFocus() }
            onAccepted: page.run(["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", text], modelData.ssid)
            BarText { visible: pw.text === ""; text: "Password"; color: Colors.dim }
          }

          Rectangle {
            id: go
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            width: 84
            height: 30
            radius: 15
            color: Colors.primary
            BarText { anchors.centerIn: parent; text: "Connect"; color: Colors.primaryText; font.pixelSize: 12 }
            MouseArea {
              anchors.fill: parent
              onClicked: page.run(["nmcli", "dev", "wifi", "connect", modelData.ssid, "password", pw.text], modelData.ssid)
            }
          }
        }
      }
    }

    BarText {
      visible: page.error !== ""
      width: parent.width
      wrapMode: Text.WordWrap
      text: page.error
      color: Colors.accent
      font.pixelSize: 12
    }

    Rectangle {
      width: 140
      height: 34
      radius: 17
      color: rescan.containsMouse ? Colors.primary : Colors.occupied
      BarText { anchors.centerIn: parent; text: "\uf021  Rescan"; color: rescan.containsMouse ? Colors.primaryText : Colors.text }
      MouseArea { id: rescan; anchors.fill: parent; hoverEnabled: true; onClicked: page.refresh(true) }
    }
  }
}
