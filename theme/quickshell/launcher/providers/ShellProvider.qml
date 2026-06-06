import QtQuick
import Quickshell

Item {
    id: root
    visible: false

    property string prefix: "> "
    property string name: "Command"
    property string placeholderText: "Run a shell command..."

    property var _history: []

    function query(text) {
        if (!text || !text.trim())
            return _history.slice()

        var lower = text.toLowerCase()
        var results = []
        for (var i = 0; i < _history.length; i++) {
            if (_history[i].command.toLowerCase().indexOf(lower) !== -1)
                results.push(_history[i])
        }
        return results
    }

    function activate(entry) {
        if (entry && entry.command) {
            var idx = -1
            for (var i = 0; i < _history.length; i++) {
                if (_history[i].command === entry.command) { idx = i; break }
            }
            if (idx >= 0) _history.splice(idx, 1)
            _history.unshift({ command: entry.command })
            if (_history.length > 10) _history.length = 10

            Quickshell.execDetached({ command: ["sh", "-c", entry.command] })
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
                text: modelData ? ("> " + (modelData.command || "")) : ""
                color: colors.text
                font.pointSize: 10
                font.family: "monospace"
                elide: Text.ElideRight
                width: parent.width - Math.round(20 * uiScale)
            }
        }
    }
}
