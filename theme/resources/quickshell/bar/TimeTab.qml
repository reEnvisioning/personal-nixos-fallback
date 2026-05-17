import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../lib"

Item {
    id: root

    property string timeString: ""
    property string dateString: ""
    property string batteryPct: "--"
    property string batteryStatus: ""
    property string powerProfile: "--"

    function updateClock(): void {
        const d = new Date()
        const hh = d.getHours().toString().padStart(2, "0")
        const mm = d.getMinutes().toString().padStart(2, "0")
        timeString = hh + ":" + mm

        const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        const months = ["January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"]
        dateString = days[d.getDay()] + ", " + d.getDate() + " " + months[d.getMonth()] + " " + d.getFullYear()
    }

    function refreshBattery(): void {
        batteryReader.running = false
        batteryReader.running = true
    }

    function refreshProfile(): void {
        profileReader.running = false
        profileReader.running = true
    }

    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.updateClock()
    }

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: {
            root.refreshBattery()
            root.refreshProfile()
        }
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

    Process {
        id: profileReader
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim()
                root.powerProfile = p.length > 0 ? p.charAt(0).toUpperCase() + p.slice(1) : "--"
            }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 5

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.timeString
            color: Colors.text
            font.pointSize: 28
            font.family: "Monospace"
            font.weight: Font.Light
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.dateString
            color: Colors.subtext0
            font.pointSize: 10
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 160; height: 1
            color: Colors.surface2
            Layout.topMargin: 2; Layout.bottomMargin: 2
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            ColumnLayout {
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\u{1F50B} " + root.batteryPct + "%"
                    color: Colors.text; font.pointSize: 11
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.batteryStatus
                    color: Colors.subtext0; font.pointSize: 9
                    visible: root.batteryStatus.length > 0
                }
            }

            ColumnLayout {
                spacing: 2
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\u26A1 " + root.powerProfile
                    color: Colors.text; font.pointSize: 11
                }
                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Power profile"
                    color: Colors.subtext0; font.pointSize: 9
                }
            }
        }
    }
}
