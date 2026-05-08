import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        id: panel
        color: "@bg@"
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

                Rectangle { width: parent.width; height: 2; color: "@bg@" }

                Rectangle {
                    width: parent.width
                    height: 50
                    color: "@bg@"
                    border.color: "@borderFocused@"
                    border.width: 1

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
                onEntered: panel.isExpanded = true
                onExited: panel.isExpanded = false
            }
        }
    }
}
