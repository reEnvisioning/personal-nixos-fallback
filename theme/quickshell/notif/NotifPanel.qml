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

    implicitWidth: Math.round(380 * root.uiScale)
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

            // Replaceable indicators (Volume, DnD, etc.) bypass DnD blocking
            // so they can show their state even when DnD is active
            if (root.replaceableAppNames.indexOf(notification.appName) >= 0) {
                for (var i = 0; i < notifColumn.children.length; i++) {
                    var child = notifColumn.children[i]
                    if (!child.dismissing && child.isReusable && child.notifAppName === notification.appName) {
                        child.updateFrom(notification)
                        notification.dismiss()
                        return
                    }
                }
                // First arrival — create card directly
                var card = notifCardComponent.createObject(notifColumn, {
                    notif: notification,
                    colors: root.colors,
                    uiScale: root.uiScale,
                    isReusable: true
                })
                card.dismissed.connect(function() { card.destroy() })
                return
            }

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
                uiScale: root.uiScale,
                isReusable: false
            })

            card.dismissed.connect(function() {
                card.destroy()
            })
        }
    }

    // --- Replaceable indicator appNames ---

    property var replaceableAppNames: [
        "Volume Indicator",
        "Brightness Indicator",
        "DnD Indicator",
        "Hypridle Indicator",
        "Theme Indicator",
        "Mic Indicator",
        "Battery Indicator",
        "Power Profile Indicator",
        "Wallpaper Indicator"
    ]

    // --- Startup notification (catches IPC notif from switch-theme etc.) ---

    Process {
        id: startupReader
        command: ["sh", "-c",
            "f=\"$XDG_RUNTIME_DIR/$(hostname)-startup-notif\";" +
            "if [ -f \"$f\" ]; then" +
            "  app=$(sed -n '1p' \"$f\");" +
            "  sum=$(sed -n '2p' \"$f\");" +
            "  body=$(sed -n '3p' \"$f\");" +
            "  notify-send --app-name=\"$app\" --expire-time=4000 \"$sum\" \"$body\";" +
            "  rm -f \"$f\";" +
            "fi"]
        running: true
    }

    // --- DnD ---

    property bool dndActive: false

    Process {
        id: dndWatcher
        command: ["sh", "-c",
            "while [ ! -f \"$XDG_RUNTIME_DIR/$(hostname)-dnd\" ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify \"$XDG_RUNTIME_DIR/$(hostname)-dnd\""]
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
        command: ["sh", "-c", "cat \"$XDG_RUNTIME_DIR/$(hostname)-dnd\""]
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
        command: ["sh", "-c",
            "while [ ! -f \"$XDG_RUNTIME_DIR/$(hostname)-notif-dismiss\" ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify \"$XDG_RUNTIME_DIR/$(hostname)-notif-dismiss\""]
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
        command: ["sh", "-c", "cat \"$XDG_RUNTIME_DIR/$(hostname)-notif-dismiss\""]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var v = parseInt(text.trim())
                if (v === 1) root.dismissAll()
            }
        }
    }
}
