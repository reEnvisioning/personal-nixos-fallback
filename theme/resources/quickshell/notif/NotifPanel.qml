import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import "../lib"

PanelWindow {
    id: root

    required property var colors

    required property real uiScale

    function activeCount() {
        var c = 0
        for (var i = 0; i < notifColumn.children.length; i++)
            if (!notifColumn.children[i].dismissing) c++
        return c
    }

    anchors.top: true
    anchors.right: true
    margins { top: Math.round(8 * root.uiScale); right: Math.round(8 * root.uiScale) }

    width: Math.round(380 * root.uiScale)
    implicitHeight: notifColumn.height

    color: "transparent"
    focusable: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-notifications"

    Column {
        id: notifColumn
        width: parent.width
        spacing: Math.round(6 * root.uiScale)
    }

    Component {
        id: notifCardComponent
        NotifCard {}
    }

    NotificationServer {
        id: notifServer
        imageSupported: true
        actionsSupported: true
        bodyMarkupSupported: true
        keepOnReload: false

        onNotification: (notification) => {
            notification.tracked = true

            if (root.dndActive) return

            while (root.activeCount() >= 4) {
                for (var i = 0; i < notifColumn.children.length; i++) {
                    if (!notifColumn.children[i].dismissing) {
                        notifColumn.children[i].startExit()
                        break
                    }
                }
            }

            var card = notifCardComponent.createObject(notifColumn, {
                notif: notification,
                colors: root.colors,
                uiScale: root.uiScale
            })

            card.dismissed.connect(function() {
                card.destroy()
            })
        }
    }

    // --- DnD ---

    property bool dndActive: false

    Process {
        id: dndWatcher
        command: ["bash", "-c",
            "while [ ! -f /tmp/headspace-dnd ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify /tmp/headspace-dnd"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                dndReader.running = false
                dndReader.running = true
                dndWatcher.running = false
                dndWatcher.running = true
            }
        }
    }

    Process {
        id: dndReader
        command: ["cat", "/tmp/headspace-dnd"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.dndActive = text.trim() === "1"
            }
        }
    }

    onDndActiveChanged: {
        if (root.dndActive) root.dismissAll()
    }

    // --- Dismiss-all IPC ---

    function dismissAll() {
        var children = notifColumn.children
        for (var i = children.length - 1; i >= 0; i--)
            children[i].startExit()
    }

    Process {
        id: dismissWatcher
        command: ["bash", "-c",
            "while [ ! -f /tmp/headspace-notif-dismiss ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify /tmp/headspace-notif-dismiss"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                dismissReader.running = false
                dismissReader.running = true
                dismissWatcher.running = false
                dismissWatcher.running = true
            }
        }
    }

    Process {
        id: dismissReader
        command: ["cat", "/tmp/headspace-notif-dismiss"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseInt(text.trim())
                if (v === 1) root.dismissAll()
            }
        }
    }
}
