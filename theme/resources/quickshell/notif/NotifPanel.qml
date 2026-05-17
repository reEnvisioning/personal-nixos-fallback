import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications
import "../lib"

PanelWindow {
    id: root

    required property var colors

    anchors.top: true
    anchors.right: true
    margins { top: 8; right: 8 }

    width: 380
    implicitHeight: notifColumn.height

    color: "transparent"
    focusable: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "headspace-notifications"

    Column {
        id: notifColumn
        width: parent.width
        spacing: 6
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

            var children = notifColumn.children
            while (children.length >= 5) {
                children[0].startExit()
                children = notifColumn.children
            }

            var card = notifCardComponent.createObject(notifColumn, {
                notif: notification,
                colors: root.colors
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
