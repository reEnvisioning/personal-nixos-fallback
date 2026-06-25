//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

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

    property real uiScale: 1

    // ── Unified config file (shell.json) ──────────────────────────────────
    readonly property string configDir: {
        var d = Quickshell.shellDir
        return d.substring(0, d.lastIndexOf("/"))
    }
    readonly property string configPath: configDir + "/reEnvisioning/shell.json"

    FileView {
        id: configFile
        path: root.configPath
        watchChanges: true
        onFileChanged: reload()
        onLoaded: applyConfig()
        onAdapterUpdated: applyConfig()

        JsonAdapter {
            id: config
            property real uiScale: 1
            property var colors: ({})
            property string themeName: ""
            property string mode: "dark"
        }
    }

    function applyConfig() {
        if (config.uiScale !== undefined) root.uiScale = config.uiScale
        colors.parse(config.colors)
    }

    // ── Components ────────────────────────────────────────────────────────
    Colors {
        id: colors
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
        id: bar
        colors: colors
        uiScale: root.uiScale
    }

    NotifPanel {
        id: notifPanel
        colors: colors
        uiScale: root.uiScale
    }

    Launcher {
        id: launcher
        colors: colors
        uiScale: root.uiScale
    }

    // ── IPC handler (replaces all $XDG_RUNTIME_DIR file watchers) ────────
    IpcHandler {
        id: ipc
        target: "panel"

        property bool dndActive: false
        property int activeTab: -1
        property bool launcherOpen: false
        property bool clipPanelVisible: false

        onDndActiveChanged: notifPanel.dndActive = dndActive
        onActiveTabChanged: {
            if (activeTab >= 0 && activeTab <= 2)
                bar.activateTab(activeTab)
        }
        onLauncherOpenChanged: {
            if (launcherOpen) {
                if (!launcher.isOpen) launcher.open()
            } else {
                if (launcher.isOpen) launcher.close()
            }
        }
        onClipPanelVisibleChanged: clipPanel.showPanel = clipPanelVisible

        function toggleDnd(force: string) {
            if (force === "1" || force === true || force === 1)
                dndActive = true
            else if (force === "0" || force === false || force === 0)
                dndActive = false
            else
                dndActive = !dndActive
        }
        function dismissNotifications() {
            notifPanel.dismissAll()
        }
        function toggleLauncher() {
            if (launcher.isOpen) {
                launcher.close()
                launcherOpen = false
            } else {
                launcher.open()
                launcherOpen = true
            }
        }
        function toggleClipboard() {
            clipPanelVisible = !clipPanelVisible
        }
        function setTab(index: string) {
            activeTab = parseInt(index)
        }
        function showStartupNotif(app: string, summary: string, body: string) {
            Quickshell.execDetached(["notify-send",
                "--app-name=" + app, "--expire-time=4000", summary, body])
        }
        function configReloaded() {
            configFile.reload()
            launcher.refreshWallpapers()
        }
        function pushTextClip() {
            clipMon.readTextClip()
        }
        function pushImageClip(name: string) {
            clipMon.addImageClip(name)
        }
    }

    // ── Mutual exclusion: launcher vs clipboard ───────────────────────────
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