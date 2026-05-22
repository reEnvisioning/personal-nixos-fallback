import QtQuick
import Quickshell
import Quickshell.Widgets
import "../scripts/fuzzysort.js" as Fuzzy

QtObject {
    id: root

    property string prefix: "! "
    property string name: "Apps"
    property string placeholderText: "Search applications..."

    property var _allApps: []

    Component.onCompleted: {
        try {
            if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
                var model = DesktopEntries.applications
                if (model.values)
                    _allApps = model.values
                else {
                    var arr = []
                    for (var i = 0; i < model.count; i++)
                        arr.push(model.get(i))
                    _allApps = arr
                }
            }
        } catch (e) {
            console.log("AppProvider: DesktopEntries error:", e)
        }
    }

    function toAppArray(text) {
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

    function query(text) {
        return toAppArray(text)
    }

    function activate(entry) {
        if (entry && entry.command) {
            Quickshell.execDetached({ command: entry.command })
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
                        text: modelData ? (modelData.comment || modelData.genericName || "") : ""
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
