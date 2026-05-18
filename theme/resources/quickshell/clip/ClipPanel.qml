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

    anchors.bottom: true
    anchors.left: true

    property bool showPanel: false
    property bool pinned: false

    readonly property real panelW: Math.round(380 * root.uiScale)
    readonly property real hiddenX: -(root.panelW + Math.round(20 * root.uiScale))

    property real slideOffset: root.hiddenX

    anchors.leftMargin: root.slideOffset
    anchors.bottomMargin: Math.round(8 * root.uiScale)

    Behavior on anchors.leftMargin {
        NumberAnimation {
            duration: 300
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.34, 1.56, 0.25, 1.0]
        }
    }

    width: root.panelW
    implicitHeight: Math.min(content.height + Math.round(44 * root.uiScale), Math.round(500 * root.uiScale))

    color: "transparent"
    focusable: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-clipboard"

    Rectangle {
        id: panelBg
        anchors.fill: parent
        radius: Math.round(12 * root.uiScale)
        color: root.colors.background

        Behavior on color { CAnim {} }
    }

    ColumnLayout {
        id: content
        x: 0; y: 0
        width: parent.width
        spacing: 0

        // Header row: title + pin button
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

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(6 * root.uiScale)
                anchors.verticalCenter: parent.verticalCenter
                width: Math.round(24 * root.uiScale)
                height: Math.round(24 * root.uiScale)
                radius: Math.round(6 * root.uiScale)
                color: pinArea.containsMouse ? root.colors.surface2 : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: root.pinned ? "\u{1F4CC}" : "\u{1F4CE}"
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
        }

        // Clip list or empty state
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
                    id: clipRepeater
                    model: root.clipMon.history

                    delegate: ClipItem {
                        clipData: model
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

    onShowPanelChanged: {
        root.slideOffset = root.showPanel ? Math.round(8 * root.uiScale) : root.hiddenX
    }
}
