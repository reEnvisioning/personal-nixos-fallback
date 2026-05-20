import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var entries: []

    property string _lastText: ""

    Component.onCompleted: load()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: poll()
    }

    function poll() {
        pollProcess.running = false
        pollProcess.running = true
    }

    Process {
        id: pollProcess
        command: ["sh", "-c",
            'txt=$(timeout 1 wl-paste --type text/plain 2>/dev/null); ' +
            'if [ -n "$txt" ]; then echo "TYPE:text"; echo "$txt"; exit 0; fi; ' +
            'echo "TYPE:none"']
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                if (lines.length < 1) return
                var typeLine = lines[0]
                if (typeLine === "TYPE:none") return

                if (typeLine === "TYPE:text") {
                    var txt = lines.slice(1).join("\n")
                    if (txt.length > 0 && txt !== root._lastText) {
                        root._lastText = txt
                        root.addClip(txt)
                    }
                }
            }
        }
    }

    function addClip(txt) {
        if (root.entries.length > 0 && root.entries[0].content === txt)
            return

        root.entries = [{ type: "text", content: txt, preview: txt.substring(0, 80), timestamp: Date.now() }].concat(root.entries)

        if (root.entries.length > 50)
            root.entries = root.entries.slice(0, 50)

        save()
    }

    function removeAt(index) {
        root.entries = root.entries.filter(function(_, i) { return i !== index })
        save()
    }

    function clearAll() {
        root.entries = []
        Quickshell.execDetached(["sh", "-c",
            "echo '[]' > $HOME/.local/share/headspace/clip-history.json && " +
            "rm -rf $HOME/.local/share/headspace/clips"])
    }

    function copyAt(index) {
        if (index < 0 || index >= root.entries.length) return
        Quickshell.clipboardText = root.entries[index].content
    }

    function save() {
        var json = JSON.stringify(root.entries)
        var delim = "HS" + Math.random().toString(36).substring(2, 10) + "EOF"
        saveProcess.command = ["sh", "-c",
            "mkdir -p $HOME/.local/share/headspace && " +
            "cat > $HOME/.local/share/headspace/clip-history.json << '" + delim + "'\n" +
            json + "\n" +
            delim]
        saveProcess.running = false
        saveProcess.running = true
    }

    Process {
        id: saveProcess
        command: ["true"]
        running: false
    }

    function load() {
        loadProcess.running = false
        loadProcess.running = true
    }

    Process {
        id: loadProcess
        command: ["sh", "-c", "cat $HOME/.local/share/headspace/clip-history.json 2>/dev/null || echo '[]'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var arr = JSON.parse(text.trim())
                    if (Array.isArray(arr))
                        root.entries = arr
                } catch (e) {
                    console.log("ClipMon: load error: " + e)
                }
            }
        }
    }
}
