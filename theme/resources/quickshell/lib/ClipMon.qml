import QtQuick
import Quickshell.Io

Item {
    id: root

    ListModel { id: clipModel }

    property alias history: clipModel

    property string _lastText: ""
    property string _lastUris: ""
    property int _lastImgSize: -1

    signal clipAdded(int index)

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
            'chk=$(wl-paste --type image/png 2>/dev/null | head -c 1); ' +
            'if [ -n "$chk" ]; then ' +
            '  ts=$(date +%s%N); p="$HOME/.local/share/headspace/clips/img_${ts}.png"; ' +
            '  mkdir -p "$HOME/.local/share/headspace/clips"; ' +
            '  wl-paste --type image/png > "$p" 2>/dev/null; echo "TYPE:image"; echo "$p"; exit 0; ' +
            'fi; ' +
            'txt=$(wl-paste --type text/plain 2>/dev/null); ' +
            'if [ -n "$txt" ]; then echo "TYPE:text"; echo "$txt"; exit 0; fi; ' +
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
                        root.addClip("image", imgPath, "Image")
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
        if (clipModel.count > 0) {
            var first = clipModel.get(0)
            if (first.type === type && JSON.stringify(first.content) === JSON.stringify(content))
                return
        }

        clipModel.insert(0, {
            type: type,
            content: content,
            preview: preview,
            timestamp: Date.now()
        })

        while (clipModel.count > 50)
            clipModel.remove(clipModel.count - 1, 1)

        clipAdded(0)
        save()
    }

    function removeAt(index) {
        clipModel.remove(index, 1)
        save()
    }

    function clearAll() {
        clipModel.clear()
        save()
    }

    function copyAt(index) {
        var item = clipModel.get(index)
        if (item.type === "text") {
            var escaped = item.content.replace(/'/g, "'\\''")
            copyProcess.command = ["sh", "-c", "printf '%s' '" + escaped + "' | wl-copy"]
        } else if (item.type === "file") {
            var uris = item.content.join("\n").replace(/'/g, "'\\''")
            copyProcess.command = ["sh", "-c", "printf '%s' '" + uris + "' | wl-copy --type text/uri-list"]
        } else if (item.type === "image") {
            copyProcess.command = ["sh", "-c", "wl-copy --type image/png < '" + item.content.replace(/'/g, "'\\''") + "'"]
        }
        copyProcess.running = false
        copyProcess.running = true
    }

    Process {
        id: copyProcess
        command: ["true"]
        running: false
    }

    function save() {
        var arr = []
        for (var i = 0; i < clipModel.count; i++)
            arr.push(clipModel.get(i))
        var json = JSON.stringify(arr)
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
                        clipModel.clear()
                        for (var i = 0; i < arr.length; i++)
                            clipModel.append(arr[i])
                    }
                } catch (e) {
                    console.log("ClipMon: load error: " + e)
                }
            }
        }
    }
}
