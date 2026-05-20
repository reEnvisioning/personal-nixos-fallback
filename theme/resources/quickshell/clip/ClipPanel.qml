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
    property int currentIndex: 0

    width: Math.round(380 * root.uiScale)
    implicitHeight: Math.round(36 * root.uiScale) + 1
        + (root.clipMon.entriesModel.count > 0
            ? Math.min(root.clipMon.entriesModel.count * Math.round(50 * root.uiScale),
                       Math.round(420 * root.uiScale))
            : Math.round(40 * root.uiScale))
        + Math.round(6 * root.uiScale)

    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-clipboard"
    visible: root.showPanel

    onShowPanelChanged: {
        if (root.showPanel) root.currentIndex = 0
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
        }

        // Divider
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.colors.surface2
            Layout.leftMargin: Math.round(8 * root.uiScale)
            Layout.rightMargin: Math.round(8 * root.uiScale)
        }

        // Clip list area
        Item {
            id: listArea
            Layout.fillWidth: true
            Layout.preferredHeight: root.clipMon.entriesModel.count > 0
                ? Math.min(root.clipMon.entriesModel.count * Math.round(50 * root.uiScale),
                           Math.round(420 * root.uiScale))
                : Math.round(40 * root.uiScale)
            Layout.bottomMargin: Math.round(6 * root.uiScale)
            clip: true

            Text {
                anchors.centerIn: parent
                text: "Clipboard is empty"
                color: root.colors.subtext0
                font.pointSize: 9
                visible: root.clipMon.entriesModel.count === 0
            }

            ListView {
                id: listView
                width: parent.width
                height: parent.height
                model: root.clipMon.entriesModel
                delegate: ClipItem {
                    entry: modelData
                    clipMon: root.clipMon
                    colors: root.colors
                    uiScale: root.uiScale
                    clipIndex: index
                    selected: index === root.currentIndex
                    width: listView.width - Math.round(8 * root.uiScale)
                    x: Math.round(4 * root.uiScale)
                    onItemClicked: root.currentIndex = index
                    onCopyRequested: root.showPanel = false
                }
                spacing: Math.round(2 * root.uiScale)
                boundsBehavior: Flickable.StopAtBounds
                focus: true
                visible: root.clipMon.entriesModel.count > 0

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.currentIndex >= 0 && root.currentIndex < root.clipMon.entriesModel.count) {
                            root.clipMon.copyAt(root.currentIndex)
                            root.showPanel = false
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                        root.clipMon.clearAll()
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.ShiftModifier)) {
                        if (root.currentIndex >= 0 && root.currentIndex < root.clipMon.entriesModel.count) {
                            root.clipMon.removeAt(root.currentIndex)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        if (root.currentIndex > 0) root.currentIndex--
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        if (root.currentIndex < root.clipMon.entriesModel.count - 1) root.currentIndex++
                        event.accepted = true
                    }
                }
            }
        }
    }

    // IPC toggle
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
