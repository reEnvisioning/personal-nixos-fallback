import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors.top: true
        width: 200
        height: isExpanded ? 52 : 2
        x: (Screen.width - width) / 2
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: false

        property bool isExpanded: false

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
                    visible: parent.parent.parent.isExpanded

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
                onEntered: parent.parent.isExpanded = true
                onExited: parent.parent.isExpanded = false
            }
        }
    }
}
