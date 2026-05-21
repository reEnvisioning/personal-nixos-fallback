import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var entries: []
    property int maxEntries: 50
    property bool _skipNextImage: false

    Component.onCompleted: {
        load()
        Qt.callLater(function() {
            seedProcess.running = false
            seedProcess.running = true
        })
    }

    // --- TEXT clipboard monitoring ---

    Process {
        id: pasteWatchText
        command: ["wl-paste", "--watch", "sh", "-c",
            "wl-paste -t text/plain 2>/dev/null > /tmp/hs-clip-t-data && " +
            "echo ok > /tmp/hs-clip-t-trigger"]
        running: true
    }

    Process {
        id: textWatcher
        command: ["sh", "-c",
            "while [ ! -f /tmp/hs-clip-t-trigger ]; do sleep 0.1; done && " +
            "inotifywait -qq -e close_write /tmp/hs-clip-t-trigger 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                textReader.running = false
                textReader.running = true
                textWatcher.running = false
                textWatcher.running = true
            }
        }
    }

    Process {
        id: textReader
        command: ["cat", "/tmp/hs-clip-t-data"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = text.trim()
                if (txt.length > 0)
                    root.addClip(txt)
            }
        }
    }

    // --- IMAGE clipboard monitoring ---

    Process {
        id: pasteWatchImg
        command: ["wl-paste", "--watch", "sh", "-c",
            "sleep 0.2 && " +
            "wl-paste -t image/png 2>/dev/null > /tmp/hs-clip-i-raw.png && " +
            "ts=$(date +%s)_$$ && " +
            "mkdir -p $HOME/.local/share/headspace/clips && " +
            "cp /tmp/hs-clip-i-raw.png $HOME/.local/share/headspace/clips/$ts.png && " +
            "echo \"$ts.png\" > /tmp/hs-clip-i-data && " +
            "echo ok > /tmp/hs-clip-i-trigger"]
        running: true
    }

    Process {
        id: imgWatcher
        command: ["sh", "-c",
            "while [ ! -f /tmp/hs-clip-i-trigger ]; do sleep 0.1; done && " +
            "inotifywait -qq -e close_write /tmp/hs-clip-i-trigger 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                imgReader.running = false
                imgReader.running = true
                imgWatcher.running = false
                imgWatcher.running = true
            }
        }
    }

    Process {
        id: imgReader
        command: ["cat", "/tmp/hs-clip-i-data"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var fname = text.trim()
                if (fname.length > 0)
                    root.addImageClip(fname)
            }
        }
    }

    // Seed: captures current text clipboard on startup
    Process {
        id: seedProcess
        command: ["wl-paste", "-t", "text/plain"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = text.trim()
                if (txt.length > 0)
                    root.addClip(txt)
            }
        }
    }

    // --- Entry management ---

    function addClip(txt) {
        for (var i = 0; i < root.entries.length; i++) {
            if (root.entries[i].content === txt) {
                var match = root.entries[i]
                root.entries.splice(i, 1)
                root.entries = [match].concat(root.entries)
                save()
                return
            }
        }

        root.entries = [{
            mimeType: "text/plain",
            content: txt,
            preview: txt.substring(0, 80),
            timestamp: Date.now(),
            pinned: false,
            truncated: txt.length > 80,
            charCount: txt.length,
            storagePath: ""
        }].concat(root.entries)

        while (root.entries.length > root.maxEntries)
            root.entries = root.entries.slice(0, root.maxEntries)

        save()
    }

    function addImageClip(fname) {
        if (root._skipNextImage) {
            root._skipNextImage = false
            return
        }
        for (var i = 0; i < root.entries.length; i++) {
            if (root.entries[i].content === fname) {
                var match = root.entries[i]
                root.entries.splice(i, 1)
                root.entries = [match].concat(root.entries)
                save()
                return
            }
        }

        root.entries = [{
            mimeType: "image/png",
            content: fname,
            preview: fname,
            timestamp: Date.now(),
            pinned: false,
            truncated: false,
            charCount: 0,
            storagePath: "clips/" + fname
        }].concat(root.entries)

        while (root.entries.length > root.maxEntries)
            root.entries = root.entries.slice(0, root.maxEntries)

        save()
    }

    function removeAt(index) {
        var entry = root.entries[index]
        if (entry && entry.storagePath && entry.storagePath.length > 0) {
            Quickshell.execDetached(["sh", "-c",
                "rm -f $HOME/.local/share/headspace/" + entry.storagePath])
        }
        root.entries = root.entries.filter(function(_, i) { return i !== index })
        save()
    }

    function clearAll() {
        root.entries = []
        Quickshell.execDetached(["sh", "-c",
            "echo '[]' > $HOME/.local/share/headspace/clip-history.json && " +
            "rm -rf $HOME/.local/share/headspace/clips"])
    }

    function togglePin(index) {
        var entry = root.entries[index]
        if (!entry) return
        entry.pinned = !entry.pinned
        var pinned = root.entries.filter(function(e) { return e.pinned })
        var unpinned = root.entries.filter(function(e) { return !e.pinned })
        root.entries = pinned.concat(unpinned)
        save()
    }

    function copyAt(index) {
        if (index < 0 || index >= root.entries.length) return
        var entry = root.entries[index]
        if (entry.mimeType === "image/png" && entry.storagePath) {
            root._skipNextImage = true
            Quickshell.execDetached(["sh", "-c",
                "cat \"$HOME/.local/share/headspace/" + entry.storagePath + "\" | wl-copy --type image/png"])
        } else if (entry.mimeType === "text/uri-list") {
            Quickshell.execDetached(["wl-copy", "-t", "text/uri-list", entry.content])
        } else {
            Quickshell.execDetached(["wl-copy", entry.content])
        }
        if (index !== 0) {
            root.entries.splice(index, 1)
            root.entries = [entry].concat(root.entries)
            save()
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
                        for (var i = 0; i < arr.length; i++) {
                            var e = arr[i]
                            if (!e.mimeType) e.mimeType = "text/plain"
                            if (!e.storagePath) e.storagePath = ""
                            if (!e.charCount) e.charCount = e.content ? e.content.length : 0
                            if (!e.pinned) e.pinned = false
                            if (!e.truncated) e.truncated = e.content && e.content.length > 80
                        }
                        root.entries = arr
                    }
                } catch (e) {
                    console.log("ClipMon: load error: " + e)
                }
            }
        }
    }
}
