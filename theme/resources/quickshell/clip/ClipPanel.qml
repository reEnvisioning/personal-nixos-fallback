import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../lib"

PanelWindow {
    id: root

    required property var colors
    required property var clipMon
    required property real uiScale

    property bool showPanel: false
    property bool pinned: false

    width: Math.round(380 * root.uiScale)
    implicitHeight: Math.min(header.height + listContent, Math.round(500 * root.uiScale))

    readonly property real listContent: root.clipMon.history.count > 0
        ? Math.max(listView.contentHeight, Math.round(20 * root.uiScale)) + Math.round(8 * root.uiScale)
        : Math.round(40 * root.uiScale)

    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-clipboard"
    visible: root.showPanel

    onShowPanelChanged: {
        if (root.showPanel) {
            root.x = Math.round(8 * root.uiScale)
            root.y = root.screen
                ? root.screen.height - root.height - Math.round(8 * root.uiScale)
                : Math.round(8 * root.uiScale)
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: Math.round(12 * root.uiScale)
        color: root.colors.background

        Behavior on color { CAnim {} }
    }

    ColumnLayout {
        width: parent.width
        spacing: 0

        // Header
        Item {
            id: header
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

            Row {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(6 * root.uiScale)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(4 * root.uiScale)

                Rectangle {
                    width: Math.round(24 * root.uiScale)
                    height: Math.round(24 * root.uiScale)
                    radius: Math.round(6 * root.uiScale)
                    color: pinArea.containsMouse ? root.colors.surface2 : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: root.pinned ? "\u25C9" : "\u25CB"
                        color: root.pinned ? root.colors.accent : root.colors.subtext0
                        font.pointSize: 11
                    }

                    MouseArea {
                        id: pinArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.pinned = !root.pinned
                    }
                }

                Text {
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
            }

            // Drag handle
            MouseArea {
                anchors.fill: parent
                property real sx, sy
                onPressed: { sx = mouse.x; sy = mouse.y }
                onPositionChanged: {
                    root.x += mouse.x - sx
                    root.y += mouse.y - sy
                }
            }
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.colors.surface2
            Layout.leftMargin: Math.round(8 * root.uiScale)
            Layout.rightMargin: Math.round(8 * root.uiScale)
        }

        // Clip list or empty
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: root.clipMon.history.count > 0
                ? Math.max(listView.contentHeight, Math.round(20 * root.uiScale))
                : Math.round(40 * root.uiScale)
            Layout.bottomMargin: Math.round(6 * root.uiScale)
            clip: true

            Text {
                id: emptyText
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: root.colors.subtext0
                font.pointSize: 9
                visible: root.clipMon.history.count === 0
            }

            ListView {
                id: listView
                width: parent.width
                height: parent.height
                model: root.clipMon.history
                spacing: Math.round(2 * root.uiScale)
                visible: root.clipMon.history.count > 0
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                highlightMoveDuration: 100
                highlight: Rectangle {
                    color: "transparent"
                    border.color: "transparent"
                }

                delegate: ClipItem {
                    clipType: model.type
                    clipContent: model.content
                    clipPreview: model.preview
                    clipTimestamp: model.timestamp
                    clipMon: root.clipMon
                    colors: root.colors
                    uiScale: root.uiScale
                    clipIndex: index
                    selected: ListView.isCurrentItem
                    width: listView.width - Math.round(8 * root.uiScale)
                    x: Math.round(4 * root.uiScale)
                    onCopyRequested: root.showPanel = false
                }

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (currentIndex >= 0) {
                            root.clipMon.copyAt(currentIndex)
                            root.showPanel = false
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                        root.clipMon.clearAll()
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.ShiftModifier)) {
                        if (currentIndex >= 0) {
                            root.clipMon.removeAt(currentIndex)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        if (currentIndex > 0) currentIndex--
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        if (currentIndex < root.clipMon.history.count - 1) currentIndex++
                        event.accepted = true
                    }
                }
            }
        }
    }

    // --- IPC: toggle watcher/reader ---

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
                if (!root.pinned)
                    root.showPanel = !root.showPanel
            }
        }
    }
}
