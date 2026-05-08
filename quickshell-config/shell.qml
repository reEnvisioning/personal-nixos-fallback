import Quickshell
import QtQuick

ShellWindow {
    width: 200
    height: 2
    x: (Screen.width - width) / 2
    y: 0
    slot: "overlay"
    clip: true

    Rectangle {
        anchors.fill: parent
        color: "transparent"

        Column {
            width: parent.width

            Item { width: parent.width; height: 2 }

            Rectangle {
                width: parent.width
                height: 50
                color: "@bg@"
                border.color: "@borderFocused@"
                border.width: 1
                visible: parent.parent.height > 2

                Text {
                    text: "test"
                    anchors.centerIn: parent
                    color: "@fg@"
                    font.pixelSize: 14
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { parent.parent.parent.height = 52 }
            onExited: { parent.parent.parent.height = 2 }
        }
    }
}
