//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
// reEnvisioning

import Quickshell
import QtQuick
import Quickshell.Io
import "lib"
import "bar"
import "notif"
import "clip"
import "launcher"

ShellRoot {
    id: root
    settings.watchFiles: true

    property real uiScale: 1

    Colors {
        id: colors
    }

    Process {
        id: configReader
        command: ["sh", "-c", "cat \"$HOME/.config/$(hostname)/config.json\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const cfg = JSON.parse(text.trim())
                    if (cfg.uiScale !== undefined) root.uiScale = cfg.uiScale
                } catch (e) {
                    console.log("shell: config parse error: " + e)
                }
            }
        }
    }

    Process {
        id: configWatcher
        command: ["sh", "-c",
            "while [ ! -f \"$HOME/.config/$(hostname)/config.json\" ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify \"$HOME/.config/$(hostname)/config.json\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                configReader.running = false
                configReader.running = true
                configWatcher.running = false
                configWatcher.running = true
            }
        }
    }

    BatteryMonitor {}

    ClipMon {
        id: clipMon
    }

    ClipPanel {
        id: clipPanel
        colors: colors
        clipMon: clipMon
        uiScale: root.uiScale
    }

    Bar {
        colors: colors
        uiScale: root.uiScale
    }

    NotifPanel {
        colors: colors
        uiScale: root.uiScale
    }

    Launcher {
        id: launcher
        colors: colors
        uiScale: root.uiScale
    }

    Connections {
        target: clipPanel
        function onShowPanelChanged() {
            if (clipPanel.showPanel) launcher.close()
        }
    }

    Connections {
        target: launcher
        function onIsOpenChanged() {
            if (launcher.isOpen) clipPanel.showPanel = false
        }
    }
}
