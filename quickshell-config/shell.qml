import Quickshell
import Quickshell.Io
import QtQuick

ShellRoot {
    id: root
    property color bg: "#000000"
    property color bd: "#303030"
    property color fg: "#C2C2C2"

    PanelWindow {
        id: panel
        color: root.bg
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
            top: 0
            bottom: 0
            left: (panel.screen.width - 200) / 2
            right: (panel.screen.width - 200) / 2
        }
        aboveWindows: true
        exclusionMode: ExclusionMode.Ignore
        focusable: false

        property bool isExpanded: false

        Process {
            id: colorReader
            command: ["cat", "/tmp/headspace-colors.json"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        let c = JSON.parse(text.trim())
                        if (c.background) root.bg = c.background
                        if (c.borderFocused) root.bd = c.borderFocused
                        if (c.text) root.fg = c.text
                    } catch(e) {
                        console.log("color error: " + e)
                    }
                }
            }
        }

        Process {
            id: colorWatcher
            command: ["bash", "-c",
                "while [ ! -f /tmp/headspace-colors.json ]; do sleep 1; done;" +
                "inotifywait -qq -e close_write,modify /tmp/headspace-colors.json"]
            running: true
            stdout: StdioCollector {
                onStreamFinished: {
                    colorReader.running = false
                    colorReader.running = true
                    colorWatcher.running = false
                    colorWatcher.running = true
                }
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "transparent"

            Column {
                width: parent.width

                Rectangle { width: parent.width; height: 2; color: root.bg }

                Rectangle {
                    width: parent.width
                    height: 50
                    color: root.bg
                    border.color: root.bd
                    border.width: 1

                    Text {
                        text: "test"
                        anchors.centerIn: parent
                        color: root.fg
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
