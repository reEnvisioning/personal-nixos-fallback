import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: shellRoot
    property color bg: "#000000"
    property color bd: "#303030"
    property color fg: "#C2C2C2"

    Process {
        id: reader
        command: ["cat", "/tmp/headspace-colors.json"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    let c = JSON.parse(this.text.trim())
                    if (c.background) shellRoot.bg = c.background
                    if (c.borderFocused) shellRoot.bd = c.borderFocused
                    if (c.text) shellRoot.fg = c.text
                } catch(e) {}
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: reader.running = true
    }

    PanelWindow {
        id: panel
        color: bg
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

                Rectangle { width: parent.width; height: 2; color: bg }

                Rectangle {
                    width: parent.width
                    height: 50
                    color: bg
                    border.color: bd
                    border.width: 1

                    Text {
                        text: "test"
                        anchors.centerIn: parent
                        color: fg
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
