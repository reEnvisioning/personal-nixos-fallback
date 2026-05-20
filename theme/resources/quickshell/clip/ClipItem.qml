import QtQuick
import QtQuick.Layouts

Item {
    id: root

    required property string clipType
    required property var clipContent
    required property string clipPreview
    required property var clipTimestamp
    required property var clipMon
    required property var colors
    required property real uiScale
    required property int clipIndex
    required property bool selected

    signal copyRequested()

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
        anchors.margins: Math.round(6 * root.uiScale)
        spacing: Math.round(8 * root.uiScale)
        z: 1

        Loader {
            Layout.preferredWidth: Math.round(36 * root.uiScale)
            Layout.preferredHeight: Math.round(36 * root.uiScale)
            sourceComponent: root.clipType === "image" ? imgComp : labelComp

            Component {
                id: labelComp
                Rectangle {
                    width: Math.round(36 * root.uiScale)
                    height: Math.round(36 * root.uiScale)
                    radius: Math.round(6 * root.uiScale)
                    color: root.colors.surface2
                    Text {
                        anchors.centerIn: parent
                        text: root.clipType === "file" ? "F" : "T"
                        color: root.colors.text
                        font.pointSize: 12
                        font.weight: Font.DemiBold
                    }
                }
            }

            Component {
                id: imgComp
                Item {
                    width: Math.round(36 * root.uiScale)
                    height: Math.round(36 * root.uiScale)
                    Rectangle {
                        anchors.fill: parent
                        radius: Math.round(6 * root.uiScale)
                        color: root.colors.surface2
                        Image {
                            anchors.fill: parent; anchors.margins: 2
                            source: "file://" + root.clipContent
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize { width: 64; height: 64 }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.clipPreview.length > 0
                    ? root.clipPreview
                    : (root.clipType === "text" ? "(text)" : root.clipType === "file" ? "(files)" : "Image")
                color: root.colors.text
                font.pointSize: 9
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                text: root.clipContent
                color: root.colors.subtext0
                font.pointSize: 8
                elide: Text.ElideRight
                maximumLineCount: 1
            }
        }

        Rectangle {
            Layout.preferredWidth: Math.round(18 * root.uiScale)
            Layout.preferredHeight: Math.round(18 * root.uiScale)
            visible: mouseArea.containsMouse
            radius: Math.round(4 * root.uiScale)
            color: "transparent"

            Text {
                anchors.centerIn: parent
                text: "\u00D7"
                color: root.colors.text
                font.pointSize: 11
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        z: 2
        onClicked: {
            if (mouse.x > root.width - Math.round(24 * root.uiScale)) {
                root.clipMon.removeAt(root.clipIndex)
            } else {
                root.clipMon.copyAt(root.clipIndex)
                root.copyRequested()
            }
        }
    }


}
