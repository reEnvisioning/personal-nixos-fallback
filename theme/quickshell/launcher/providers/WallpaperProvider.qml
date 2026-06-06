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

    Process {
        id: addProc
        command: ["true"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                wallpaperLoader.running = false
                wallpaperLoader.running = true
            }
        }
    }

    Process {
        id: filePicker
        command: ["zenity", "--file-selection", "--title", "Choose a wallpaper image",
            "--file-filter", "Images (*.png *.jpg *.jpeg *.bmp *.webp)"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var path = text.trim()
                if (path.length > 0)
                    addWallpaper(path)
            }
        }
    }

    function addWallpaper(filePath) {
        addProc.command = ["bash", "-c",
            "H=$(hostname);" +
            "THEME=$(state get current-theme 2>/dev/null || true);" +
            "if [ -z \"$THEME\" ]; then exit 0; fi;" +
            "mkdir -p \"$HOME/.local/share/$H/wallpapers\";" +
            "cp \"$1\" \"$HOME/.local/share/$H/wallpapers/\";" +
            "NEW_PATH=\"$HOME/.local/share/$H/wallpapers/$(basename \"$1\")\";" +
            "if [ -f \"$HOME/.config/$H/themes/$THEME.json\" ]; then" +
            "  THEME_FILE=\"$HOME/.config/$H/themes/$THEME.json\";" +
            "else" +
            "  mkdir -p \"$HOME/.config/$H/themes\";" +
            "  cp \"/etc/$H/themes/$THEME.json\" \"$HOME/.config/$H/themes/$THEME.json\";" +
            "  THEME_FILE=\"$HOME/.config/$H/themes/$THEME.json\";" +
            "fi;" +
            "jq --arg new \"$NEW_PATH\" '.wallpapers += [$new]' \"$THEME_FILE\" > \"${THEME_FILE}.tmp\" && " +
            "mv \"${THEME_FILE}.tmp\" \"$THEME_FILE\";" +
            "COUNT=$(jq '.wallpapers | length' \"$THEME_FILE\");" +
            "NEW_IDX=$((COUNT - 1));" +
            "switch-wallpaper \"$NEW_IDX\"",
            "addWallpaper", filePath]
        addProc.running = false
        addProc.running = true
    }

    function activate(entry) {
        if (entry && entry.isAdd) {
            filePicker.running = false
            filePicker.running = true
            return
        }
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

        if (!text || !text.trim()) {
            var results = [{ index: -1, name: "+ Add wallpaper...", isAdd: true }]
            return results.concat(_wallpapers.slice())
        }

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
                    color: modelData && modelData.isAdd === true ? colors.surface0 || "#333" : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "+"
                        color: colors.text
                        font.pointSize: 18
                        font.weight: Font.Bold
                        visible: modelData && modelData.isAdd === true
                    }

                    Image {
                        anchors.fill: parent
                        source: modelData && modelData.isAdd !== true ? modelData.fullPath : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: !modelData || modelData.isAdd !== true
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
