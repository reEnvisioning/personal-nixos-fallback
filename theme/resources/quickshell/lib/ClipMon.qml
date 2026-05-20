import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    ListModel {
        id: entriesModel
    }

    property string _lastText: ""

    Component.onCompleted: load()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: poll()
    }

    function poll() {
        var txt = Quickshell.clipboardText
        if (txt && txt.length > 0 && txt !== root._lastText) {
            root._lastText = txt
            root.addClip(txt)
        }
    }

    function addClip(txt) {
        if (entriesModel.count > 0 && entriesModel.get(0).content === txt)
            return

        entriesModel.insert(0, { type: "text", content: txt, preview: txt.substring(0, 80), timestamp: Date.now() })

        while (entriesModel.count > 50)
            entriesModel.remove(50, 1)

        save()
    }

    function removeAt(index) {
        entriesModel.remove(index, 1)
        save()
    }

    function clearAll() {
        entriesModel.clear()
        Quickshell.execDetached(["sh", "-c",
            "echo '[]' > $HOME/.local/share/headspace/clip-history.json && " +
            "rm -rf $HOME/.local/share/headspace/clips"])
    }

    function copyAt(index) {
        if (index < 0 || index >= entriesModel.count) return
        Quickshell.clipboardText = entriesModel.get(index).content
    }

    function save() {
        var arr = []
        for (var i = 0; i < entriesModel.count; i++)
            arr.push(entriesModel.get(i))

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
                        entriesModel.clear()
                        for (var i = 0; i < arr.length; i++)
                            entriesModel.append(arr[i])
                    }
                } catch (e) {
                    console.log("ClipMon: load error: " + e)
                }
            }
        }
    }
}
