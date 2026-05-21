import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property var entry
    required property var clipMon
    required property var colors
    required property real uiScale
    required property int clipIndex
    required property bool selected

    signal copyRequested()
    signal itemClicked(int index)

    width: parent ? parent.width : 380
    height: Math.round(48 * root.uiScale)

    Rectangle {
        id: bg
        anchors.fill: parent
        radius: Math.round(8 * root.uiScale)
        color: root.selected
            ? (mouseArea.containsMouse ? root.colors.highlighted : root.colors.overlay1)
            : (mouseArea.containsMouse ? root.colors.surface2 : "transparent")
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Math.round(10 * root.uiScale)
        anchors.rightMargin: Math.round(6 * root.uiScale)
        anchors.verticalCenter: parent.verticalCenter
        spacing: Math.round(4 * root.uiScale)
        z: 1

        Text {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            text: root.entry.truncated
                ? root.entry.preview + "\u2026 (" + root.entry.charCount + ")"
                : root.entry.preview
            color: root.colors.text
            font.pointSize: 10
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        Text {
            Layout.preferredWidth: Math.round(18 * root.uiScale)
            horizontalAlignment: Text.AlignHCenter
            text: root.entry.pinned ? "\u2605" : "\u2606"
            color: root.colors.text
            font.pointSize: 11
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 2
        onClicked: function(mouse) {
            if (mouse.x > root.width - Math.round(24 * root.uiScale)) {
                root.clipMon.togglePin(root.clipIndex)
            } else {
                root.clipMon.copyAt(root.clipIndex)
                root.itemClicked(root.clipIndex)
                root.copyRequested()
            }
        }
    }
}
