import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false

    property string prefix: "^ "
    property string name: "Share"
    property string placeholderText: "Share a file..."
    property int refreshKey: 0

    property var _files: []

    Process {
        id: fileScanner
        command: ["bash", "-c",
            "cd ~ && find Documents Downloads Pictures Videos Music . " +
            "-maxdepth 3 -not -path '*/.*' -type f 2>/dev/null | sort"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._files = []
                var raw = text.trim()
                if (raw === "") return
                var lines = raw.split('\n')
                for (var i = 0; i < lines.length; i++) {
                    root._files.push({
                        relPath: lines[i],
                        name: lines[i].split('/').pop()
                    })
                }
                root.refreshKey++
            }
        }
    }

    Process {
        id: filePicker
        command: ["bash", "-c",
            "cd ~ && find Documents Downloads Pictures Videos Music . " +
            "-maxdepth 3 -not -path '*/.*' -type f 2>/dev/null | " +
            "sort | kitty -T fzf sh -c 'fzf --prompt=\"Share > \" > /tmp/share-choice' && " +
            "cat /tmp/share-choice"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (path.length > 0)
                    Quickshell.execDetached(["bash", "-c",
                        "localsend_app send \"$HOME/$1\"",
                        "shareFile", path])
            }
        }
    }

    function query(text) {
        if (root._files.length === 0) return []

        if (!text || !text.trim())
            return [{ isBrowse: true }]

        var lower = text.toLowerCase()
        var results = []
        for (var i = 0; i < root._files.length; i++) {
            if (root._files[i].relPath.toLowerCase().indexOf(lower) !== -1)
                results.push(root._files[i])
        }
        return results
    }

    function textFor(entry) { return entry ? (entry.isBrowse ? "" : entry.relPath) : "" }

    function activate(entry) {
        if (!entry) return
        if (entry.isBrowse) {
            filePicker.running = false
            filePicker.running = true
        } else {
            Quickshell.execDetached(["bash", "-c",
                "localsend_app send \"$HOME/$1\"",
                "shareFile", entry.relPath])
        }
    }

    property Component itemComponent: Component {
        Item {
            required property var modelData
            required property bool selected
            required property var colors
            required property real uiScale
            height: Math.round(44 * uiScale)

            Rectangle {
                anchors.fill: parent
                color: selected ? colors.highlighted : "transparent"
                radius: Math.round(6 * uiScale)
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(10 * uiScale)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData && modelData.isBrowse ? "^ Browse via fzf..." : ("^ " + modelData.relPath)
                color: colors.text
                font.pointSize: 10
                font.family: "monospace"
                elide: Text.ElideLeft
            }
        }
    }
}
