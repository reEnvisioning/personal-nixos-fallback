import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import "../scripts/fuzzysort.js" as Fuzzy

Item {
    id: root
    visible: false

    property string prefix: "! "
    property string name: "Apps"
    property string placeholderText: "Search applications..."

    property var _allApps: []

    Process {
        id: appLoader
        command: ["bash", "-c",
            "shopt -s nullglob\n" +
            "dirs=()\n" +
            "dirs+=(\"${XDG_DATA_HOME:-$HOME/.local/share}/applications\")\n" +
            "IFS=: read -ra xdgDirs <<< \"${XDG_DATA_DIRS:-/usr/local/share:/usr/share}\"\n" +
            "for d in \"${xdgDirs[@]}\"; do dirs+=(\"${d%/}/applications\"); done\n" +
            "for dir in \"${dirs[@]}\"; do\n" +
            "  for f in \"$dir\"/*.desktop; do\n" +
            "    [ -f \"$f\" ] || continue\n" +
            "    id=\"${f##*/}\"; id=\"${id%.desktop}\"\n" +
            "    n=\"$(grep -m1 '^Name=' \"$f\" 2>/dev/null | sed 's/^Name=//')\"\n" +
            "    i=\"$(grep -m1 '^Icon=' \"$f\" 2>/dev/null | sed 's/^Icon=//')\"\n" +
            "    c=\"$(grep -m1 '^Comment=' \"$f\" 2>/dev/null | sed 's/^Comment=//')\"\n" +
            "    e=\"$(grep -m1 '^Exec=' \"$f\" 2>/dev/null | sed 's/^Exec=//' | sed 's/%[a-zA-Z]//g')\"\n" +
            "    printf '%s\\t%s\\t%s\\t%s\\t%s\\n' \"$id\" \"$n\" \"$i\" \"$c\" \"$e\"\n" +
            "  done\n" +
            "done"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split('\n')
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split('\t')
                    if (parts.length >= 5) {
                        root._allApps.push({
                            id: parts[0],
                            name: parts[1],
                            icon: parts[2],
                            comment: parts[3],
                            exec: parts[4]
                        })
                    }
                }
            }
        }
    }

    function query(text) {
        if (root._allApps.length === 0) return []

        if (!text || !text.trim()) {
            return _allApps.slice(0, 15)
        }

        var results = Fuzzy.go(text, _allApps, {
            key: "name",
            limit: 15,
            threshold: -10000
        })
        if (results.length > 0)
            return results.map(function(r) { return r.obj })

        var lower = text.toLowerCase()
        return _allApps.filter(function(a) {
            return a.name && a.name.toLowerCase().indexOf(lower) !== -1
        }).slice(0, 15)
    }

    function activate(entry) {
        if (entry && entry.exec) {
            Quickshell.execDetached({ command: ["sh", "-c", entry.exec] })
        }
    }

    property Component itemComponent: Component {
        Item {
            required property var modelData
            required property bool selected
            height: 44

            Rectangle {
                anchors.fill: parent
                color: selected ? "#494949" : "transparent"
                radius: 6
                Behavior on color { ColorAnimation { duration: 80 } }
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                IconImage {
                    anchors.verticalCenter: parent.verticalCenter
                    width: 24
                    height: 24
                    source: modelData ? Quickshell.iconPath(modelData.icon, "image-missing") : ""
                    asynchronous: true
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 1

                    Text {
                        text: modelData ? (modelData.name || "Unknown") : ""
                        color: "#C2C2C2"
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        width: parent.parent ? parent.parent.width - 44 : 400
                    }

                    Text {
                        text: modelData ? (modelData.comment || "") : ""
                        color: "#AAAAAA"
                        font.pointSize: 8
                        elide: Text.ElideRight
                        width: parent.parent ? parent.parent.width - 44 : 400
                        visible: text !== ""
                    }
                }
            }
        }
    }
}
