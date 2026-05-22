import QtQuick

Item {
    id: root
    visible: false

    property string prefix: ""
    property string name: ""
    property string placeholderText: ""

    function query(text) { return []; }

    function activate(entry) {}

    property Component itemComponent: Component {
        Item {
            required property var modelData
            required property bool selected
            height: 40

            Rectangle {
                anchors.fill: parent
                color: selected ? "#494949" : "transparent"
                radius: 6

                Behavior on color {
                    ColorAnimation { duration: 80 }
                }
            }

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: modelData ? (modelData.name || modelData.toString()) : ""
                color: "#C2C2C2"
                font.pointSize: 10
                elide: Text.ElideRight
                width: parent.width - 20
            }
        }
    }
}
