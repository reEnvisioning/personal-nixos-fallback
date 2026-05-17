//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded

import Quickshell
import "lib"
import "bar"

ShellRoot {
    settings.watchFiles: true

    Bar {}
}
