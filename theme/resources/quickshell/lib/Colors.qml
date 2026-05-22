import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property color background: "#000000"
    property color backgroundAccent: "#494949"
    property color highlighted: "#616161"
    property color text: "#C2C2C2"
    property color borderInactive: "#181818"
    property color borderFocused: "#303030"
    property color accent: "#000000"
    property color accent_light: "#000000"
    property color accent_dark: "#000000"
    property color red: "#464646"
    property color green: "#484848"
    property color yellow: "#4A4A4A"
    property color blue: "#4C4C4C"
    property color magenta: "#4E4E4E"
    property color cyan: "#505050"
    property color mauve: "#494949"
    property color lavender: "#4A4A4A"
    property color pink: "#484848"
    property color rosewater: "#464646"
    property color flamingo: "#474747"
    property color maroon: "#4B4B4B"
    property color peach: "#4C4C4C"
    property color sky: "#4D4D4D"
    property color sapphire: "#4E4E4E"
    property color surface2: "#494949"
    property color overlay1: "#494949"
    property color overlay2: "#494949"
    property color crust: "#000000"
    property color subtext0: "#AAAAAA"
    property color subtext1: "#B6B6B6"
    property string themeName: ""
    property string mode: "dark"

    function parse(data: string): void {
        try {
            const j = JSON.parse(data.trim())
            for (const key in j) {
                if (key === "name")
                    root.themeName = j.name
                else if (key === "mode")
                    root.mode = j.mode
                else if (root.hasOwnProperty(key))
                    root[key] = j[key]
            }
        } catch (e) {
            console.log("Colors: parse error: " + e)
        }
    }

    Process {
        id: colorReader
        command: ["sh", "-c", "cat \"$XDG_RUNTIME_DIR/headspace-colors.json\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
    }

    Process {
        id: colorWatcher
        command: ["bash", "-c",
            "while [ ! -f \"$XDG_RUNTIME_DIR/headspace-colors.json\" ]; do sleep 1; done;" +
            "inotifywait -qq -e close_write,modify \"$XDG_RUNTIME_DIR/headspace-colors.json\""]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                colorReader.running = false
                colorReader.running = true
                colorWatcher.running = false
                colorWatcher.running = true
            }
        }
    }
}
