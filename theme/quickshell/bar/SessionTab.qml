import QtQuick
import QtQuick.Layouts
import "../lib"

Item {
    id: root

    required property var colors

    property bool dndActive: false
    property string proxyStatus: "disabled"
    property string idleStatus: "unknown"

    function statusColor(status: string): color {
        if (status === "connected" || status === "enabled") return root.colors.green
        if (status === "pending") return root.colors.yellow
        if (status === "offline" || status === "active") return root.colors.peach
        return root.colors.subtext0
    }

    function indicatorColor(value: bool): color {
        return value ? root.colors.peach : root.colors.subtext0
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10
        width: 200

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                color: root.indicatorColor(root.dndActive)
                Behavior on color { CAnim {} }
            }
            Text {
                text: "DND"
                color: root.colors.subtext0; font.pointSize: 10; font.weight: Font.DemiBold
                Behavior on color { CAnim {} }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: root.dndActive ? "Active" : "Inactive"
                color: root.dndActive ? root.colors.peach : root.colors.text
                font.pointSize: 10
                Behavior on color { CAnim {} }
            }
        }

        Rectangle {
            Layout.fillWidth: true; height: 1
            color: root.colors.surface2
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                color: root.statusColor(root.idleStatus)
                Behavior on color { CAnim {} }
            }
            Text {
                text: "Idle"
                color: root.colors.subtext0; font.pointSize: 10; font.weight: Font.DemiBold
                Behavior on color { CAnim {} }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: {
                    if (root.idleStatus === "enabled") return "Enabled"
                    if (root.idleStatus === "disabled") return "Disabled"
                    return "Unknown"
                }
                color: {
                    if (root.idleStatus === "enabled") return root.colors.green
                    if (root.idleStatus === "disabled") return root.colors.text
                    return root.colors.subtext0
                }
                font.pointSize: 10
                Behavior on color { CAnim {} }
            }
        }

        Rectangle {
            Layout.fillWidth: true; height: 1
            color: root.colors.surface2
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 8
            Rectangle {
                width: 8; height: 8; radius: 4
                color: root.statusColor(root.proxyStatus)
                Behavior on color { CAnim {} }
            }
            Text {
                text: "Proxy"
                color: root.colors.subtext0; font.pointSize: 10; font.weight: Font.DemiBold
                Behavior on color { CAnim {} }
            }
            Item { Layout.fillWidth: true }
            Text {
                text: {
                    if (root.proxyStatus === "connected") return "Connected"
                    if (root.proxyStatus === "pending") return "Pending"
                    if (root.proxyStatus === "offline") return "Offline"
                    if (root.proxyStatus === "disconnected") return "Disconnected"
                    return "Disabled"
                }
                color: root.statusColor(root.proxyStatus)
                font.pointSize: 10
                Behavior on color { CAnim {} }
            }
        }
    }
}
