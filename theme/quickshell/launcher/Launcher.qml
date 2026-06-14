import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../lib"
import "providers"

PanelWindow {
    id: root

    required property var colors
    required property real uiScale

    property real panelWidth: Math.round(520 * root.uiScale)
    property real inputHeight: Math.round(40 * root.uiScale)
    property real itemHeight: Math.round(44 * root.uiScale)
    property real emptyListHeight: Math.round(44 * root.uiScale)
    property real fullHeight: Math.round(500 * root.uiScale)
    property bool isOpen: false
    property real animHeight: 0
    property bool _pendingCleanup: false
    property var _pendingActivate: null

    property list<QtObject> providers: [
        AppProvider { id: appProv },
        ShellProvider { id: shellProv },
        TerminalProvider { id: terminalProv },
        SSHProvider { id: sshProv },
        ThemeProvider { id: themeProv },
        WallpaperProvider { id: wallpaperProv },
        SystemProvider { id: systemProv },
        ShareProvider { id: shareProv },
        EmojiProvider { id: emojiProv },
        CalcProvider { id: calcProv }
    ]

    Connections {
        target: wallpaperProv
        function onRefreshKeyChanged() {
            if (root.activeProvider === wallpaperProv)
                root.processInput(inputField.text)
        }
    }

    Connections {
        target: shareProv
        function onRefreshKeyChanged() {
            if (root.activeProvider === shareProv)
                root.processInput(inputField.text)
        }
    }

    property var activeProvider: null
    property string queryText: ""
    property var results: []
    property int currentIndex: 0

    implicitWidth: root.panelWidth
    implicitHeight: root.fullHeight
    visible: root.animHeight > 0
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-launcher"
    anchors.bottom: true
    margins {
        bottom: Math.round(8 * root.uiScale)
        left: Math.round((root.screen.width - root.panelWidth) / 2)
        right: Math.round((root.screen.width - root.panelWidth) / 2)
    }

    NumberAnimation {
        id: heightAnim
        target: root
        property: "animHeight"
    }

    Connections {
        target: heightAnim
        function onFinished() {
            if (root._pendingActivate) {
                var pending = root._pendingActivate
                root._pendingActivate = null
                pending.provider.activate(pending.entry)
            }
        }
    }

    function animateTo(h, dur, curve) {
        if (h === heightAnim.to && heightAnim.running) return
        heightAnim.stop()
        heightAnim.from = root.animHeight
        heightAnim.to = h
        heightAnim.duration = dur
        heightAnim.easing.type = Easing.Bezier
        heightAnim.easing.bezierCurve = curve || [0.34, 0.8, 0.34, 1.0]
        heightAnim.start()
    }

    function computeMaxListHeight() {
        return Math.round(root.screen.height / 3) - root.inputHeight - Math.round(13 * root.uiScale)
    }

    function computeListHeight() {
        if (root.results.length > 0) {
            var spacing = Math.round(2 * root.uiScale)
            var contentH = root.results.length * root.itemHeight + (root.results.length - 1) * spacing
            contentH = Math.min(contentH, root.computeMaxListHeight())
            return Math.round(13 * root.uiScale) + contentH
        }
        if (root.activeProvider && root.queryText)
            return root.emptyListHeight
        return 0
    }

    function open() {
        if (!root.isOpen)
            root.isOpen = true
        resetState()
        Qt.callLater(function() { inputField.forceActiveFocus() })
    }

    function close() {
        root.isOpen = false
        root.activeProvider = null
        root.results = []
        root.currentIndex = 0
        root._pendingCleanup = false
        rebuildItems()
        animateTo(0, 400, [0.3, 0, 1, 1, 1, 1])
    }

    function resetState() {
        root._pendingActivate = null
        root._pendingCleanup = false
        root.activeProvider = null
        root.queryText = ""
        root.results = []
        root.currentIndex = 0
        inputField.text = ""
        rebuildItems()
        animateTo(root.inputHeight + root.computeListHeight(), 500, [0.38, 1.21, 0.22, 1.0])
    }

    function processInput(text) {
        for (var i = 0; i < root.providers.length; i++) {
            var p = root.providers[i]
            var plen = p.prefix.length
            if (text.length >= plen && text.substring(0, plen) === p.prefix) {
                if (root.activeProvider !== p) {
                    root.activeProvider = p
                    root.currentIndex = 0
                }
                root.queryText = text.substring(plen)
                root.results = p.query(root.queryText)
                root._pendingCleanup = false
                rebuildItems()
                updateTargetHeight()
                return
            }
        }

        if (root.activeProvider !== null || root.results.length > 0) {
            root.activeProvider = null
            root.results = []
            root._pendingCleanup = false
            rebuildItems()
            updateTargetHeight()
        }
    }

    function updateTargetHeight() {
        var h = root.inputHeight + root.computeListHeight()
        if (h === root.animHeight) return
        animateTo(h, 600, [0.05, 0.7, 0.1, 1, 1, 1])
    }

    function selectCurrent() {
        root._pendingActivate = null
        if (root.activeProvider && root.currentIndex >= 0 && root.currentIndex < root.results.length) {
            var provider = root.activeProvider
            var entry = root.results[root.currentIndex]

            if (provider.closeOnActivate !== false) {
                root._pendingActivate = { provider: provider, entry: entry }
                close()
            } else {
                provider.activate(entry)
                inputField.text = provider.prefix
            }
        }
    }

    function moveSel(delta) {
        var len = root.results.length
        if (len === 0) return
        root.currentIndex = (root.currentIndex + delta + len) % len
        ensureVisible()
    }

    function ensureVisible() {
        if (root.results.length === 0) return
        var spacing = Math.round(2 * root.uiScale)
        var y = root.currentIndex * (root.itemHeight + spacing)
        if (y < resultFlick.contentY)
            resultFlick.contentY = y
        else if (y + root.itemHeight > resultFlick.contentY + resultFlick.height)
            resultFlick.contentY = y + root.itemHeight - resultFlick.height
    }

    Item {
        id: contentWrapper
        anchors.bottom: parent.bottom
        width: parent.width
        height: root.animHeight
        clip: true

        Rectangle {
            anchors.fill: parent
            radius: Math.round(12 * root.uiScale)
            color: root.colors.background
            Behavior on color { CAnim {} }
        }

        Item {
            id: resultArea
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Math.round(4 * root.uiScale)
            anchors.bottom: inputBar.top
            anchors.bottomMargin: Math.round(1 * root.uiScale)
            clip: true

            Text {
                anchors.centerIn: parent
                text: "No results"
                color: root.colors.subtext0
                font.pointSize: 9
                visible: root.activeProvider && root.queryText && root.results.length === 0
            }

            Flickable {
                id: resultFlick
                anchors.fill: parent
                anchors.margins: Math.round(4 * root.uiScale)
                contentHeight: resultCol.height
                boundsBehavior: Flickable.StopAtBounds
                interactive: root.results.length > 0
                clip: true
                visible: root.results.length > 0

                Column {
                    id: resultCol
                    width: parent.width
                    spacing: Math.round(2 * root.uiScale)
                }
            }
        }

        Item {
            id: inputBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: root.inputHeight

            Rectangle {
                anchors.fill: parent
                anchors.margins: Math.round(4 * root.uiScale)
                radius: Math.round(8 * root.uiScale)
                color: root.colors.surface2
            }

            TextInput {
                id: inputField
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Math.round(12 * root.uiScale)
                anchors.right: providerLabel.left
                anchors.rightMargin: Math.round(6 * root.uiScale)
                color: root.colors.text
                font.pointSize: 10
                clip: true
                cursorVisible: true

                onTextChanged: root.processInput(text)

                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        root.selectCurrent()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Backspace && inputField.text === "") {
                        root.close()
                        event.accepted = true
                    } else if ((event.key === Qt.Key_Tab || event.key === Qt.Key_Right) && root.activeProvider && root.results.length > 0) {
                        if (event.key === Qt.Key_Right && inputField.cursorPosition < inputField.text.length) {
                            return
                        }
                        var entry = root.results[root.currentIndex]
                        inputField.text = root.activeProvider.prefix + root.activeProvider.textFor(entry)
                        inputField.cursorPosition = inputField.text.length
                        event.accepted = true
                    } else if (event.key === Qt.Key_Up) {
                        if (root.results.length > 0) {
                            root.moveSel(-1)
                            event.accepted = true
                        }
                    } else if (event.key === Qt.Key_Down) {
                        if (root.results.length > 0) {
                            root.moveSel(1)
                            event.accepted = true
                        }
                    } else if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier) && root.activeProvider && root.results.length > 0) {
                        var prov = root.activeProvider
                        if (typeof prov.remove !== "function") { return }
                        if (event.modifiers & Qt.ShiftModifier) {
                            prov.removeAll()
                        } else {
                            prov.remove(root.results[root.currentIndex])
                        }
                        root.processInput(inputField.text)
                        event.accepted = true
                    } else if (event.key === Qt.Key_P && (event.modifiers & Qt.ControlModifier) && root.activeProvider && root.results.length > 0) {
                        var prov = root.activeProvider
                        if (typeof prov.altActivate !== "function") { return }
                        prov.altActivate(root.results[root.currentIndex])
                        if (prov.closeOnActivate !== false)
                            close()
                        else
                            inputField.text = prov.prefix
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        if (root.activeProvider || root.results.length > 0 || inputField.text !== "") {
                            root.activeProvider = null
                            root.results = []
                            root._pendingCleanup = false
                            inputField.text = ""
                            rebuildItems()
                            updateTargetHeight()
                        } else {
                            close()
                        }
                        event.accepted = true
                    }
                }
            }

            Text {
                id: providerLabel
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Math.round(12 * root.uiScale)
                text: root.activeProvider ? root.activeProvider.name : ""
                color: root.colors.subtext0
                font.pointSize: 8
                visible: text !== ""
            }
        }
    }

    Process {
        id: toggleWatcher
        command: ["sh", "-c",
            "while [ ! -f \"$XDG_RUNTIME_DIR/$(hostname)-launcher-toggle\" ]; do sleep 0.2; done;" +
            "inotifywait -qq -e close_write,modify,create \"$XDG_RUNTIME_DIR/$(hostname)-launcher-toggle\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.isOpen)
                    root.close()
                else
                    root.open()
                toggleWatcher.running = false
                toggleWatcher.running = true
            }
        }
    }

    function rebuildItems() {
        resultFlick.contentY = 0
        var children = resultCol.children
        for (var i = children.length - 1; i >= 0; i--)
            children[i].destroy()

        if (!root.activeProvider || root.results.length === 0) return

        var comp = root.activeProvider.itemComponent
        if (!comp) return

        for (var i = 0; i < root.results.length; i++) {
            comp.createObject(resultCol, {
                width: resultCol.width,
                modelData: root.results[i],
                selected: i === root.currentIndex,
                colors: root.colors,
                uiScale: root.uiScale
            })
        }
    }

    onCurrentIndexChanged: {
        for (var i = 0; i < resultCol.children.length; i++) {
            var child = resultCol.children[i]
            if (child && child.hasOwnProperty("selected"))
                child.selected = (i === root.currentIndex)
        }
        ensureVisible()
    }
}
