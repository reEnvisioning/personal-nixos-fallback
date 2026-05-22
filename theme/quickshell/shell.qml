//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

import Quickshell
import "lib"
import "bar"
import "notif"
import "clip"

ShellRoot {
    id: root
    settings.watchFiles: true

    property real uiScale: 1 // scale-config

    Colors {
        id: colors
    }

    BatteryMonitor {}

    ClipMon {
        id: clipMon
    }

    ClipPanel {
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
}
