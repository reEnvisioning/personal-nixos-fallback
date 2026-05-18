import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../lib"

ShellWindow {
    id: root

    required property var colors
    required property var clipMon
    required property real uiScale

    property bool showPanel: false

    width: Math.round(380 * root.uiScale)
    height: Math.min(content.height + Math.round(44 * root.uiScale), Math.round(500 * root.uiScale))
    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    visible: root.showPanel

    onShowPanelChanged: {
        if (root.showPanel) {
            root.x = Math.round(8 * root.uiScale)
            root.y = root.screen.height - root.height - Math.round(8 * root.uiScale)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.round(12 * root.uiScale)
        color: root.colors.background

        Behavior on color { CAnim {} }
    }

    ColumnLayout {
        id: content
        width: parent.width
        spacing: 0

        Item {
            Layout.fillWidth: true
            height: Math.round(36 * root.uiScale)

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(10 * root.uiScale)
                anchors.verticalCenter: parent.verticalCenter
                text: "Clipboard"
                color: root.colors.text
                font.pointSize: 10
                font.weight: Font.DemiBold
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(8 * root.uiScale)
                anchors.verticalCenter: parent.verticalCenter
                text: "Clear"
                color: clearArea.containsMouse ? root.colors.red : root.colors.subtext0
                font.pointSize: 9

                MouseArea {
                    id: clearArea
                    anchors.fill: parent
                    anchors.margins: -Math.round(4 * root.uiScale)
                    hoverEnabled: true
                    onClicked: root.clipMon.clearAll()
                }
            }

            MouseArea {
                anchors.fill: parent
                property real dragX
                property real dragY
                onPressed: { dragX = mouse.x; dragY = mouse.y }
                onPositionChanged: {
                    root.x += mouse.x - dragX
                    root.y += mouse.y - dragY
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.clipMon.history.count > 0 ? listArea.height : emptyText.height
            Layout.bottomMargin: Math.round(6 * root.uiScale)

            Text {
                id: emptyText
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: root.colors.subtext0
                font.pointSize: 9
                visible: root.clipMon.history.count === 0
            }

            Column {
                id: listArea
                width: parent.width
                spacing: Math.round(2 * root.uiScale)
                visible: root.clipMon.history.count > 0

                Repeater {
                    model: root.clipMon.history

                    delegate: ClipItem {
                        clipType: type
                        clipContent: content
                        clipPreview: preview
                        clipTimestamp: timestamp
                        clipMon: root.clipMon
                        colors: root.colors
                        uiScale: root.uiScale
                        clipIndex: index
                        width: listArea.width - Math.round(8 * root.uiScale)
                        x: Math.round(4 * root.uiScale)
                    }
                }
            }
        }
    }

    Process {
        id: toggleWatcher
        command: ["bash", "-c",
            "while [ ! -f /tmp/headspace-clip-toggle ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify /tmp/headspace-clip-toggle"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                toggleReader.running = false
                toggleReader.running = true
                toggleWatcher.running = false
                toggleWatcher.running = true
            }
        }
    }

    Process {
        id: toggleReader
        command: ["cat", "/tmp/headspace-clip-toggle"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                root.showPanel = !root.showPanel
            }
        }
    }
}
