import QtQuick
import Quickshell

Item {
    id: root
    visible: false

    property string prefix: "> "
    property string name: "Command"
    property string placeholderText: "Run a shell command..."

    function query(text) {
        if (!text || !text.trim())
            return []
        return [{ command: text }]
    }

    function activate(entry) {
        if (entry && entry.command)
            Quickshell.execDetached({ command: ["sh", "-c", entry.command] })
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
