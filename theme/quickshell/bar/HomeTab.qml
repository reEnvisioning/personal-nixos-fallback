import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../lib"

Item {
    id: root

    required property var colors

    property string userName: ""
    property string hostName: ""
    property string timeString: ""
    property string dateString: ""
    property string batteryPct: "--"
    property string batteryStatus: ""

    Process {
        id: userReader
        command: ["sh", "-c", "echo $USER"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.userName = text.trim()
        }
    }

    Process {
        id: infoReader
        command: ["sh", "-c", "echo host=$(hostname)"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const data = text.trim()
                const lines = data.split("\n")
                for (const line of lines) {
                    const idx = line.indexOf("=")
                    if (idx < 0) continue
                    const key = line.slice(0, idx)
                    const val = line.slice(idx + 1)
                    if (key === "host") root.hostName = val
                }
            }
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: {
            infoReader.running = false
            infoReader.running = true
        }
    }

    function updateClock(): void {
        const d = new Date()
        const hh = d.getHours().toString().padStart(2, "0")
        const mm = d.getMinutes().toString().padStart(2, "0")
        timeString = hh + ":" + mm

        const days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        dateString = days[d.getDay()] + ", " + d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear()
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.updateClock()
    }

    function refreshBattery(): void {
        batteryReader.running = false
        batteryReader.running = true
    }

    Process {
        id: batteryReader
        command: ["sh", "-c", "c=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo --); s=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null); echo \"$c $s\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                root.batteryPct = parts[0] || "--"
                root.batteryStatus = parts.length > 1 ? parts[1] : ""
            }
        }
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: root.refreshBattery()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Math.round(4)
        spacing: Math.round(6)

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(52)
            spacing: Math.round(10)

            Rectangle {
                width: Math.round(40); height: Math.round(40)
                radius: Math.round(20)
                clip: true
                color: "transparent"
                border.width: 2
                border.color: root.colors.accent
                Behavior on border.color { CAnim {} }

                Image {
                    anchors.centerIn: parent
                    width: Math.round(36); height: Math.round(36)
                    sourceSize { width: 36; height: 36 }
                    source: root.userName ? "../user/" + root.userName + ".png" : ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            ColumnLayout {
                spacing: Math.round(2)

                Text {
                    text: root.userName + "@" + (root.hostName.length > 0 ? root.hostName : "...")
                    color: root.colors.text
                    font.pointSize: 11
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                    Behavior on color { CAnim {} }
                }

                Text {
                    text: root.colors.themeName
                    color: root.colors.subtext0
                    font.pointSize: 9
                    elide: Text.ElideRight
                    Behavior on color { CAnim {} }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.batteryPct + "%"
                color: root.colors.text
                font.pointSize: 11
                font.weight: Font.DemiBold
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { CAnim {} }
            }

            Text {
                text: root.batteryStatus
                color: root.colors.subtext0
                font.pointSize: 9
                visible: root.batteryStatus.length > 0
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { CAnim {} }
            }
        }

        Item { Layout.fillWidth: true }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Math.round(4)

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.timeString
                color: root.colors.text
                font.pointSize: 30
                font.family: "Monospace"
                font.weight: Font.Light
                Behavior on color { CAnim {} }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: root.dateString
                color: root.colors.subtext0
                font.pointSize: 10
                Behavior on color { CAnim {} }
            }
        }

        Item { Layout.fillWidth: true }
    }
}
