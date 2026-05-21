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
    property string searchText: ""

    width: Math.round(380 * root.uiScale)
    implicitHeight: Math.round(36 * root.uiScale) + 1
        + (root.clipMon.entries.length > 0
            ? Math.min(root.clipMon.entries.length * Math.round(50 * root.uiScale),
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
        if (root.showPanel) {
            root.searchText = ""
            root.currentIndex = 0
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

        Item {
            id: header
            Layout.fillWidth: true
            height: Math.round(36 * root.uiScale)

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(10 * root.uiScale)
                anchors.verticalCenter: parent.verticalCenter
                text: root.searchText || "Clipboard"
                color: root.colors.text
                font.pointSize: 10
                font.weight: Font.DemiBold
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: root.colors.surface2
            Layout.leftMargin: Math.round(8 * root.uiScale)
            Layout.rightMargin: Math.round(8 * root.uiScale)
        }

        Item {
            id: listArea
            Layout.fillWidth: true
            Layout.preferredHeight: root.clipMon.entries.length > 0
                ? Math.min(root.clipMon.entries.length * Math.round(50 * root.uiScale),
                           Math.round(420 * root.uiScale))
                : Math.round(40 * root.uiScale)
            Layout.bottomMargin: Math.round(6 * root.uiScale)
            clip: true

            Text {
                anchors.centerIn: parent
                text: root.searchText ? "No matching entries" : "Clipboard is empty"
                color: root.colors.subtext0
                font.pointSize: 9
                visible: root.clipMon.entries.length === 0 || (root.searchText && clipColumn.children.length === 0)
            }

            Flickable {
                id: clipFlickable
                width: parent.width
                height: parent.height
                contentHeight: clipColumn.height
                boundsBehavior: Flickable.StopAtBounds
                interactive: root.clipMon.entries.length > 0
                clip: true
                visible: root.clipMon.entries.length > 0
                focus: true

                Column {
                    id: clipColumn
                    width: parent.width
                    spacing: Math.round(2 * root.uiScale)
                }

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        if (root.currentIndex >= 0 && root.currentIndex < root.clipMon.entries.length) {
                            root.clipMon.copyAt(root.currentIndex)
                            root.showPanel = false
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                        confirmOverlay.visible = true
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.ShiftModifier)) {
                        if (root.currentIndex >= 0 && root.currentIndex < root.clipMon.entries.length) {
                            root.clipMon.removeAt(root.currentIndex)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        if (root.currentIndex > 0) root.currentIndex--
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        if (root.currentIndex < root.clipMon.entries.length - 1) root.currentIndex++
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        root.searchText = ""
                        event.accepted = true
                    } else if (event.key === Qt.Key_Backspace) {
                        root.searchText = root.searchText.substring(0, root.searchText.length - 1)
                        event.accepted = true
                    } else if (!(event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.AltModifier) && !(event.modifiers & Qt.MetaModifier)) {
                        if (event.text.length > 0) {
                            root.searchText += event.text
                            event.accepted = true
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: confirmOverlay
        anchors.fill: parent
        visible: false
        color: Qt.rgba(0, 0, 0, 0.5)
        z: 10

        Rectangle {
            anchors.centerIn: parent
            width: parent.width * 0.75
            height: Math.round(80 * root.uiScale)
            radius: Math.round(8 * root.uiScale)
            color: root.colors.background

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Math.round(8 * root.uiScale)
                spacing: Math.round(8 * root.uiScale)

                Text {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    text: "Clear all clipboard history?"
                    color: root.colors.text
                    font.pointSize: 10
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Math.round(8 * root.uiScale)

                    Item { Layout.fillWidth: true }

                    Rectangle {
                        Layout.preferredWidth: Math.round(60 * root.uiScale)
                        Layout.preferredHeight: Math.round(28 * root.uiScale)
                        radius: Math.round(4 * root.uiScale)
                        color: root.colors.surface2

                        Text {
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: root.colors.text
                            font.pointSize: 9
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: confirmOverlay.visible = false
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: Math.round(60 * root.uiScale)
                        Layout.preferredHeight: Math.round(28 * root.uiScale)
                        radius: Math.round(4 * root.uiScale)
                        color: root.colors.highlighted

                        Text {
                            anchors.centerIn: parent
                            text: "Clear"
                            color: root.colors.text
                            font.pointSize: 9
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                root.clipMon.clearAll()
                                confirmOverlay.visible = false
                            }
                        }
                    }
                }
            }
        }
    }

    Component {
        id: itemComponent
        ClipItem {}
    }

    Component.onCompleted: rebuildClipItems()

    onCurrentIndexChanged: {
        for (var i = 0; i < clipColumn.children.length; i++) {
            var child = clipColumn.children[i]
            if (child.clipIndex !== undefined)
                child.selected = child.clipIndex === root.currentIndex
        }
    }

    onSearchTextChanged: {
        if (root.clipMon.entries.length > 0) {
            if (root.currentIndex >= root.clipMon.entries.length)
                root.currentIndex = Math.max(0, root.clipMon.entries.length - 1)
        }
        rebuildClipItems()
    }

    Connections {
        target: root.clipMon
        function onEntriesChanged() {
            rebuildClipItems()
        }
    }

    function matchesSearch(entry) {
        return root.searchText === "" ||
            entry.content.toLowerCase().indexOf(root.searchText.toLowerCase()) !== -1
    }

    function rebuildClipItems() {
        var children = clipColumn.children
        for (var i = children.length - 1; i >= 0; i--)
            children[i].destroy()

        for (var i = 0; i < root.clipMon.entries.length; i++) {
            if (!matchesSearch(root.clipMon.entries[i])) continue

            var item = itemComponent.createObject(clipColumn, {
                x: Math.round(4 * root.uiScale),
                width: root.width - Math.round(8 * root.uiScale),
                entry: root.clipMon.entries[i],
                clipMon: root.clipMon,
                colors: root.colors,
                uiScale: root.uiScale,
                clipIndex: i,
                selected: i === root.currentIndex
            })
            item.itemClicked.connect(function(idx) {
                root.currentIndex = idx
            })
            item.copyRequested.connect(function() {
                root.showPanel = false
            })
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
