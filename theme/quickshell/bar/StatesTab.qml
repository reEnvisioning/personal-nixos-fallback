import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../lib"

Item {
    id: root

    required property var colors

    property bool dndActive: false
    property string proxyStatus: "disabled"
    property string idleStatus: "unknown"
    property string powerProfile: "--"

    function statusColor(status: string): color {
        if (status === "connected" || status === "enabled") return root.colors.green
        if (status === "pending") return root.colors.yellow
        if (status === "offline" || status === "active") return root.colors.peach
        return root.colors.subtext0
    }

    function indicatorColor(value: bool): color {
        return value ? root.colors.peach : root.colors.subtext0
    }

    function idleText(): string {
        if (root.idleStatus === "enabled") return "Enabled"
        if (root.idleStatus === "disabled") return "Disabled"
        return "Unknown"
    }

    function idleTextColor(): color {
        if (root.idleStatus === "enabled") return root.colors.green
        if (root.idleStatus === "disabled") return root.colors.text
        return root.colors.subtext0
    }

    function proxyText(): string {
        if (root.proxyStatus === "connected") return "Connected"
        if (root.proxyStatus === "pending") return "Pending"
        if (root.proxyStatus === "offline") return "Offline"
        if (root.proxyStatus === "disconnected") return "Disconnected"
        return "Disabled"
    }

    function refreshProfile(): void {
        profileReader.running = false
        profileReader.running = true
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

    Timer {
        interval: 5000; running: true; repeat: true
        onTriggered: root.refreshProfile()
    }

    GridLayout {
        anchors.fill: parent
        anchors.margins: Math.round(4)
        columns: 2
        rowSpacing: Math.round(6)
        columnSpacing: Math.round(6)

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(56)
            radius: Math.round(8)
            color: root.colors.surface2
            Behavior on color { CAnim {} }

            RowLayout {
                anchors.centerIn: parent
                spacing: Math.round(8)

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: root.indicatorColor(root.dndActive)
                    Behavior on color { CAnim {} }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "DND"
                        color: root.colors.subtext0
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        Behavior on color { CAnim {} }
                    }
                    Text {
                        text: root.dndActive ? "Active" : "Inactive"
                        color: root.dndActive ? root.colors.peach : root.colors.text
                        font.pointSize: 9
                        Behavior on color { CAnim {} }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(56)
            radius: Math.round(8)
            color: root.colors.surface2
            Behavior on color { CAnim {} }

            RowLayout {
                anchors.centerIn: parent
                spacing: Math.round(8)

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: root.statusColor(root.idleStatus)
                    Behavior on color { CAnim {} }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Idle"
                        color: root.colors.subtext0
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        Behavior on color { CAnim {} }
                    }
                    Text {
                        text: root.idleText()
                        color: root.idleTextColor()
                        font.pointSize: 9
                        Behavior on color { CAnim {} }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(56)
            radius: Math.round(8)
            color: root.colors.surface2
            Behavior on color { CAnim {} }

            RowLayout {
                anchors.centerIn: parent
                spacing: Math.round(8)

                Rectangle {
                    width: 8; height: 8; radius: 4
                    color: root.statusColor(root.proxyStatus)
                    Behavior on color { CAnim {} }
                }

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Proxy"
                        color: root.colors.subtext0
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        Behavior on color { CAnim {} }
                    }
                    Text {
                        text: root.proxyText()
                        color: root.statusColor(root.proxyStatus)
                        font.pointSize: 9
                        Behavior on color { CAnim {} }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(56)
            radius: Math.round(8)
            color: root.colors.surface2
            Behavior on color { CAnim {} }

            RowLayout {
                anchors.centerIn: parent
                spacing: Math.round(8)

                ColumnLayout {
                    spacing: 2
                    Text {
                        text: "Profile"
                        color: root.colors.subtext0
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        Behavior on color { CAnim {} }
                    }
                    Text {
                        text: root.powerProfile
                        color: root.colors.text
                        font.pointSize: 9
                        Behavior on color { CAnim {} }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }
    }
}
