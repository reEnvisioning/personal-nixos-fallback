import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root
    visible: false

    property string prefix: "$ "
    property string name: "Wallpaper"
    property string placeholderText: "Switch wallpaper..."

    property var _wallpapers: []

    Process {
        id: wallpaperLoader
        command: ["bash", "-c",
            "H=$(hostname);" +
            "THEME=$(state get current-theme 2>/dev/null || true);" +
            "if [ -z \"$THEME\" ]; then exit 0; fi;" +
            "if [ -f \"$HOME/.config/$H/themes/$THEME.json\" ]; then" +
            "  THEME_FILE=\"$HOME/.config/$H/themes/$THEME.json\";" +
            "elif [ -f \"/etc/$H/themes/$THEME.json\" ]; then" +
            "  THEME_FILE=\"/etc/$H/themes/$THEME.json\";" +
            "else exit 0; fi;" +
            "CURRENT_IDX=$(state get wallpaper-idx:$THEME 2>/dev/null || echo 0);" +
            "WALLPAPER_COUNT=$(jq '.wallpapers | length' \"$THEME_FILE\");" +
            "for ((idx=0; idx<WALLPAPER_COUNT; idx++)); do" +
            "  path=$(jq -r \".wallpapers[$idx]\" \"$THEME_FILE\");" +
            "  name=$(basename \"$path\");" +
            "  cur=\"false\";" +
            "  if [ \"$idx\" = \"$CURRENT_IDX\" ]; then cur=\"true\"; fi;" +
            "  printf '%s\\t%s\\t%s\\t%s\\t%s\\n' \"$idx\" \"$name\" \"$path\" \"$cur\" \"$WALLPAPER_COUNT\";" +
            "done"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root._wallpapers = []
                var raw = text.trim()
                if (raw === "") return
                var lines = raw.split('\n')
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split('\t')
                    if (parts.length >= 5) {
                        root._wallpapers.push({
                            index: parseInt(parts[0]),
                            name: parts[1],
                            fullPath: parts[2],
                            current: parts[3] === "true",
                            total: parseInt(parts[4])
                        })
                    }
                }
            }
        }
    }

    function activate(entry) {
        if (entry && entry.index !== undefined) {
            Quickshell.execDetached(["switch-wallpaper", String(entry.index)])
            for (var i = 0; i < root._wallpapers.length; i++)
                root._wallpapers[i].current = root._wallpapers[i].index === entry.index
            var tmp = root._wallpapers.slice()
            root._wallpapers = tmp
        }
    }

    function query(text) {
        if (root._wallpapers.length === 0) return []

        if (!text || !text.trim())
            return _wallpapers.slice()

        var lower = text.toLowerCase()
        return _wallpapers.filter(function(w) {
            return w.name.toLowerCase().indexOf(lower) !== -1
        })
    }

    function textFor(entry) { return entry ? entry.name : "" }

    property Component itemComponent: Component {
        Item {
            required property var modelData
            required property bool selected
            required property var colors
            required property real uiScale
            height: Math.round(48 * uiScale)

            Rectangle {
                anchors.fill: parent
                color: selected ? colors.highlighted : "transparent"
                radius: Math.round(6 * uiScale)
            }

            Row {
                anchors.left: parent.left
                anchors.leftMargin: Math.round(10 * uiScale)
                anchors.verticalCenter: parent.verticalCenter
                spacing: Math.round(10 * uiScale)

                Rectangle {
                    width: Math.round(60 * uiScale)
                    height: Math.round(36 * uiScale)
                    radius: Math.round(4 * uiScale)
                    clip: true

                    Image {
                        id: thumbImg
                        anchors.fill: parent
                        source: modelData ? modelData.fullPath : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        onStatusChanged: if (status === Image.Error) console.log("Wallpaper load error:", source)
                    }

                    Rectangle {
                        anchors.fill: parent
                        color: colors.surface0 || "#333"
                        visible: thumbImg.status !== Image.Ready
                        Text {
                            anchors.centerIn: parent
                            text: modelData ? modelData.name.charAt(0).toUpperCase() : ""
                            color: colors.subtext0 || "#888"
                            font.pointSize: 12
                        }
                    }
                }

                Text {
                    text: modelData ? ("$ " + modelData.name) : ""
                    color: colors.text
                    font.pointSize: 10
                    font.family: "monospace"
                }

                Text {
                    text: modelData && modelData.current ? "(current)" : ""
                    color: colors.green || colors.text
                    font.pointSize: 8
                    visible: text !== ""
                }
            }
        }
    }
}
