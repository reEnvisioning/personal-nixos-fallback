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
    property int visibleCount: 0
    property real desiredHeight: 0
    property real animHeight: 0
    property real slideX: 0

    width: Math.round(380 * root.uiScale)
    height: root.animHeight
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-clipboard"
    WlrLayershell.anchors.bottom: true
    WlrLayershell.anchors.left: true
    WlrLayershell.margins { bottom: Math.round(8 * root.uiScale); left: Math.round(8 * root.uiScale) }

    onShowPanelChanged: {
        if (root.showPanel) {
            root.searchText = ""
            root.currentIndex = 0
            root.desiredHeight = root.computeDesiredHeight()
            root.visible = true
            heightAnim.onFinished = undefined
            heightAnim.from = 0
            heightAnim.to = root.desiredHeight
            heightAnim.duration = 300
            heightAnim.easing.type = Easing.Bezier
            heightAnim.easing.bezierCurve = [0.34, 1.56, 0.25, 1.0]
            heightAnim.start()
            slideAnim.from = -Math.round(30 * root.uiScale)
            slideAnim.to = 0
            slideAnim.duration = 250
            slideAnim.easing.type = Easing.Bezier
            slideAnim.easing.bezierCurve = [0.34, 0.8, 0.34, 1.0]
            slideAnim.start()
        } else {
            heightAnim.stop()
            heightAnim.from = root.animHeight
            heightAnim.to = 0
            heightAnim.duration = 150
            heightAnim.easing.type = Easing.OutQuad
            heightAnim.onFinished = function() {
                root.visible = false
            }
            heightAnim.start()
        }
    }

    NumberAnimation { id: heightAnim; target: root; property: "animHeight" }
    NumberAnimation { id: slideAnim; target: root; property: "slideX" }

    Rectangle {
        anchors.fill: parent
        radius: Math.round(12 * root.uiScale)
        color: root.colors.background
        Behavior on color { CAnim {} }
    }

    ColumnLayout {
        width: parent.width
        spacing: 0
        x: root.slideX

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
            Layout.preferredHeight: root.visibleCount > 0
                ? Math.min(root.visibleCount * Math.round(50 * root.uiScale),
                           Math.round(root.screen.height / 3) - Math.round(43 * root.uiScale))
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
                    } else if (event.key === Qt.Key_S && (event.modifiers & Qt.ControlModifier)) {
                        if (root.currentIndex >= 0 && root.currentIndex < root.clipMon.entries.length)
                            root.clipMon.togglePin(root.currentIndex)
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier)) {
                        root.clipMon.clearAll()
                        event.accepted = true
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && !(event.modifiers & Qt.ShiftModifier)) {
                        if (root.currentIndex >= 0 && root.currentIndex < root.clipMon.entries.length) {
                            root.clipMon.removeAt(root.currentIndex)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        root.currentIndex = root._prevVisible(root.currentIndex)
                        event.accepted = true
                    } else if (event.key === Qt.Key_Down) {
                        root.currentIndex = root._nextVisible(root.currentIndex)
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
        if (clipFlickable.visible && clipColumn.children.length > 0) {
            var targetY = 0
            for (var i = 0; i < clipColumn.children.length; i++) {
                if (clipColumn.children[i].clipIndex === root.currentIndex) {
                    targetY = clipColumn.children[i].y
                    break
                }
            }
            if (targetY < clipFlickable.contentY)
                clipFlickable.contentY = targetY
            else if (targetY + Math.round(50 * root.uiScale) > clipFlickable.contentY + clipFlickable.height)
                clipFlickable.contentY = targetY + Math.round(50 * root.uiScale) - clipFlickable.height
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

    function computeDesiredHeight() {
        if (root.visibleCount > 0) {
            var contentH = Math.min(root.visibleCount * Math.round(50 * root.uiScale),
                Math.round(root.screen.height / 3) - Math.round(43 * root.uiScale))
            return Math.round(36 * root.uiScale) + 1 + contentH + Math.round(6 * root.uiScale)
        }
        return Math.round(36 * root.uiScale) + 1 + Math.round(40 * root.uiScale) + Math.round(6 * root.uiScale)
    }

    function matchesSearch(entry) {
        return root.searchText === "" ||
            entry.content.toLowerCase().indexOf(root.searchText.toLowerCase()) !== -1
    }

    function _prevVisible(idx) {
        for (var i = idx - 1; i >= 0; i--) {
            if (matchesSearch(root.clipMon.entries[i])) return i
        }
        return idx
    }

    function _nextVisible(idx) {
        for (var i = idx + 1; i < root.clipMon.entries.length; i++) {
            if (matchesSearch(root.clipMon.entries[i])) return i
        }
        return idx
    }

    function rebuildClipItems() {
        var children = clipColumn.children
        for (var i = children.length - 1; i >= 0; i--)
            children[i].destroy()

        root.visibleCount = 0
        for (var i = 0; i < root.clipMon.entries.length; i++) {
            if (!matchesSearch(root.clipMon.entries[i])) continue
            root.visibleCount++

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
        root.desiredHeight = root.computeDesiredHeight()
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
