import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var entries: []

    signal entriesChanged()

    property string _lastText: ""
    property string _lastUris: ""
    property int _lastImgSize: -1

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
            'uri=$(wl-paste --type text/uri-list 2>/dev/null); ' +
            'if [ -n "$uri" ]; then echo "TYPE:uri"; echo "$uri"; exit 0; fi; ' +
            'txt=$(wl-paste --type text/plain 2>/dev/null); ' +
            'if [ -n "$txt" ]; then echo "TYPE:text"; echo "$txt"; exit 0; fi; ' +
            'chk=$(wl-paste --type image/png 2>/dev/null | head -c 1); ' +
            'if [ -n "$chk" ]; then ' +
            '  ts=$(date +%s%N); p="$HOME/.local/share/headspace/clips/img_${ts}.png"; ' +
            '  mkdir -p "$HOME/.local/share/headspace/clips"; ' +
            '  wl-paste --type image/png > "$p" 2>/dev/null; echo "TYPE:image"; echo "$p"; exit 0; ' +
            'fi; ' +
            'echo "TYPE:none"']
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split("\n")
                if (lines.length < 1) return
                var typeLine = lines[0]
                if (typeLine === "TYPE:none") return

                if (typeLine === "TYPE:uri") {
                    var uri = lines.slice(1).join("\n").trim()
                    if (uri.length > 0 && uri !== root._lastUris) {
                        root._lastUris = uri
                        var uris = uri.split("\n")
                        var preview = ""
                        for (var i = 0; i < uris.length; i++) {
                            var name = uris[i].replace(/^file:\/\//, "").split("/").pop()
                            if (i > 0) preview += ", "
                            preview += name
                        }
                        root.addClip("file", uris, preview.substring(0, 100))
                    }
                } else if (typeLine === "TYPE:image") {
                    var imgPath = lines.slice(1).join("\n").trim()
                    if (imgPath.length > 0) {
                        root.addClip("image", imgPath, imgPath.split("/").pop())
                    }
                } else if (typeLine === "TYPE:text") {
                    var txt = lines.slice(1).join("\n").trim()
                    if (txt.length > 0 && txt !== root._lastText) {
                        root._lastText = txt
                        root.addClip("text", txt, txt.substring(0, 80))
                    }
                }
            }
        }
    }

    function addClip(type, content, preview) {
        if (root.entries.length > 0) {
            var first = root.entries[0]
            if (first.type === type && JSON.stringify(first.content) === JSON.stringify(content))
                return
        }

        root.entries.unshift({
            type: type,
            content: content,
            preview: preview,
            timestamp: Date.now()
        })

        while (root.entries.length > 50)
            root.entries.pop()

        root.entriesChanged()
        save()
    }

    function removeAt(index) {
        root.entries.splice(index, 1)
        root.entriesChanged()
        save()
    }

    function clearAll() {
        root.entries = []
        root.entriesChanged()
        Quickshell.execDetached(["sh", "-c",
            "echo '[]' > $HOME/.local/share/headspace/clip-history.json && " +
            "rm -rf $HOME/.local/share/headspace/clips"])
    }

    function copyAt(index) {
        if (index < 0 || index >= root.entries.length) return
        var item = root.entries[index]
        if (item.type === "text") {
            Quickshell.execDetached(["wl-copy", item.content])
        } else if (item.type === "file") {
            Quickshell.execDetached(["wl-copy", "--type", "text/uri-list", item.content.join("\n")])
        } else if (item.type === "image") {
            Quickshell.execDetached(["wl-copy", "--type", "image/png", item.content])
        }
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
                    if (Array.isArray(arr)) {
                        root.entries = arr
                        root.entriesChanged()
                    }
                } catch (e) {
                    console.log("ClipMon: load error: " + e)
                }
            }
        }
    }
}
