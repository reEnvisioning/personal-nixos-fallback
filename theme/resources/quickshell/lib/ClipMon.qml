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

    // Daemon: runs wl-paste --watch, writes clipboard text to a temp file on each change
    Process {
        id: pasteWatch
        command: ["wl-paste", "--watch", "sh", "-c",
            "wl-paste -t text/plain 2>/dev/null > /tmp/headspace-clipboard-last.txt && " +
            "echo ok > /tmp/headspace-clipboard-trigger"]
        running: true
    }

    // Watcher: blocks on inotifywait for the trigger file
    Process {
        id: clipWatcher
        command: ["sh", "-c",
            "inotifywait -qq -e close_write /tmp/headspace-clipboard-trigger 2>/dev/null"]
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

    // Reader: reads the clipboard content temp file
    Process {
        id: clipReader
        command: ["cat", "/tmp/headspace-clipboard-last.txt"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var txt = text.trim()
                if (txt.length > 0 && root.entries.length > 0 && root.entries[0].content === txt)
                    return
                if (txt.length > 0)
                    root.addClip(txt)
            }
        }
    }

    // Seed: one-shot read of current clipboard on startup
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
            charCount: txt.length
        }].concat(root.entries)

        while (root.entries.length > root.maxEntries)
            root.entries = root.entries.slice(0, root.maxEntries)

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
        if (entry.mimeType === "text/uri-list")
            Quickshell.execDetached(["wl-copy", "-t", "text/uri-list", entry.content])
        else
            Quickshell.execDetached(["wl-copy", entry.content])
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
