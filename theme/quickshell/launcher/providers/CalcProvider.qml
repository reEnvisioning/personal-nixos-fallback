import QtQuick
import Quickshell

Item {
    id: root
    visible: false

    property string prefix: "= "
    property string name: "Calc"
    property string placeholderText: "Calculate..."

    function query(text) {
        if (!text || !text.trim()) return []
        var result = evaluate(text)
        if (result === null) return []
        return [{ expression: text, result: result }]
    }

    function evaluate(expr) {
        try {
            var result = Function('"use strict"; return (' + expr + ')')()
            return result !== undefined ? String(result) : null
        } catch (e) {
            return null
        }
    }

    function textFor(entry) { return entry ? entry.result : "" }

    function activate(entry) {
        if (entry && entry.result)
            Quickshell.execDetached(["wl-copy", entry.result])
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
                text: modelData ? ("= " + modelData.expression) : ""
                color: colors.text
                font.pointSize: 10
                font.family: "monospace"
            }

            Text {
                anchors.right: parent.right
                anchors.rightMargin: Math.round(10 * uiScale)
                anchors.verticalCenter: parent.verticalCenter
                text: modelData ? ("= " + modelData.result) : ""
                color: colors.green || colors.subtext0
                font.pointSize: 10
                font.family: "monospace"
            }
        }
    }
}
