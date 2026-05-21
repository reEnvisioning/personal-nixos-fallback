import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property var entries: []
    property int maxEntries: 50

    Component.onCompleted: {
        load()
        Qt.callLater(function() {
            seedProcess.running = false
            seedProcess.running = true
        })
    }

    // --- Event-driven clipboard monitoring via wl-paste --watch + inotifywait IPC ---

    // Daemon: runs wl-paste --watch, dispatches by MIME type on each clipboard change
    Process {
        id: pasteWatch
        command: ["wl-paste", "--watch", "sh", "-c",
            "types=$(wl-paste --list-types 2>/dev/null)\n" +
            "if echo \"$types\" | grep -q \"text/plain\"; then\n" +
            "  wl-paste -t text/plain > /tmp/headspace-clip-data\n" +
            "  echo text/plain > /tmp/headspace-clip-mime\n" +
            "  echo ok > /tmp/headspace-clip-trigger\n" +
            "elif echo \"$types\" | grep -q \"text/uri-list\"; then\n" +
            "  wl-paste -t text/uri-list > /tmp/headspace-clip-data\n" +
            "  echo text/uri-list > /tmp/headspace-clip-mime\n" +
            "  echo ok > /tmp/headspace-clip-trigger\n" +
            "elif echo \"$types\" | grep -q \"image/png\"; then\n" +
            "  ts=$(date +%s%3N)\n" +
            "  mkdir -p $HOME/.local/share/headspace/clips\n" +
            "  wl-paste -t image/png > $HOME/.local/share/headspace/clips/$ts.png\n" +
            "  echo \"$ts.png\" > /tmp/headspace-clip-data\n" +
            "  echo image/png > /tmp/headspace-clip-mime\n" +
            "  echo ok > /tmp/headspace-clip-trigger\n" +
            "fi"
        ]
        running: true
    }

    // Watcher: blocks on inotifywait for the trigger file
    Process {
        id: clipWatcher
        command: ["sh", "-c",
            "while [ ! -f /tmp/headspace-clip-trigger ]; do sleep 0.1; done && " +
            "inotifywait -qq -e close_write /tmp/headspace-clip-trigger 2>/dev/null"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                clipReader.running = false
                clipReader.running = true
                clipWatcher.running = false
                clipWatcher.running = true
            }
        }
    }

    // Reader: reads MIME type + data after a clipboard change
    Process {
        id: clipReader
        command: ["sh", "-c", "cat /tmp/headspace-clip-mime /tmp/headspace-clip-data"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split('\n')
                var mime = lines[0].trim()
                var data = lines.slice(1).join('\n').trim()
                if (data.length === 0) return
                if (mime === "image/png")
                    root.addImageClip(data)
                else
                    root.addClip(data, mime)
            }
        }
    }

    // Seed: captures current clipboard content on startup
    Process {
        id: seedProcess
        command: ["wl-paste", "-t", "text/plain"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = text.trim()
                if (txt.length > 0 && (root.entries.length === 0 || root.entries[0].content !== txt))
                    root.addClip(txt)
            }
        }
    }

    // --- Entry management ---

    function addClip(txt, mime) {
        if (!mime) mime = "text/plain"
        if (root.entries.length > 0 && root.entries[0].content === txt)
            return

        root.entries = [{
            mimeType: mime,
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
        if (root.entries.length > 0 && root.entries[0].content === fname)
            return

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
            Quickshell.execDetached(["sh", "-c",
                "wl-copy -t image/png < $HOME/.local/share/headspace/" + entry.storagePath])
        } else if (entry.mimeType === "text/uri-list") {
            Quickshell.execDetached(["wl-copy", "-t", "text/uri-list", entry.content])
        } else {
            Quickshell.execDetached(["wl-copy", entry.content])
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
