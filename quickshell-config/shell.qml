import Quickshell
import QtQuick
import "Colors" as Colors

ShellRoot {
    PanelWindow {
        id: panel
        color: Colors.background
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: isExpanded ? 52 : 2

        Behavior on implicitHeight {
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        margins {
            left: (Screen.width - 200) / 2
            right: (Screen.width - 200) / 2
        }
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: false

        property bool isExpanded: false

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            Column {
                width: parent.width

                Rectangle { width: parent.width; height: 2; color: Colors.background }

                Rectangle {
                    width: parent.width
                    height: 50
                    color: Colors.background
                    border.color: Colors.borderFocused
                    border.width: 1

                    Text {
                        text: "test"
                        anchors.centerIn: parent
                        color: Colors.text
                        font.pixelSize: 14
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: panel.isExpanded = true
                onExited: panel.isExpanded = false
            }
        }
    }
}
