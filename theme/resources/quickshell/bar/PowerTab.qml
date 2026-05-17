import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    required property var colors

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            model: [
                { label: "Shutdown",   cmd: ["systemctl", "poweroff"] },
                { label: "Reboot",     cmd: ["systemctl", "reboot"] },
                { label: "Logout",     cmd: ["loginctl", "terminate-user", "visionary"] },
                { label: "Lock",       cmd: ["loginctl", "lock-session"] },
            ]

            delegate: Item {
                required property var modelData

                implicitWidth: 200
                implicitHeight: 28

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: ma.containsMouse ? root.colors.highlighted : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                }

                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.label
                    color: root.colors.text
                    font.pointSize: 11
                }

                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(modelData.cmd)
                }
            }
        }
    }
}
