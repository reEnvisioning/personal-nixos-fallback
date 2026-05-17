import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    required property var colors

    property real collapsedHeight: 2
    property real expandedHeight: 180
    property bool isExpanded: false
    property int activeTab: 0

    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins { left: 6; right: 6 }

    color: "transparent"
    focusable: false
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    implicitHeight: root.isExpanded ? root.expandedHeight : root.collapsedHeight

    Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
    }

    Rectangle {
        id: bg
        y: -12
        width: parent.width
        height: parent.height + 12
        radius: 12
        color: root.colors.background

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    Item {
        id: contentRoot
        anchors.fill: parent
        visible: root.isExpanded
        clip: true

        Item {
            id: tabRow
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 26

            Row {
                anchors.fill: parent

                Repeater {
                    model: ["\u23FB Power", "\u{1F550} Time", "\u2699 System"]

                    delegate: Item {
                        required property int index
                        required property string modelData

                        width: tabRow.width / 3
                        height: tabRow.height

                        Text {
                            anchors.centerIn: parent
                            text: modelData
                            color: root.activeTab === index ? root.colors.text : root.colors.subtext0
                            font.pointSize: 10
                            font.weight: root.activeTab === index ? Font.DemiBold : Font.Normal

                            Behavior on color {
                                ColorAnimation { duration: 100 }
                            }
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: parent.width * 0.4
                            height: root.activeTab === index ? 2 : 0
                            radius: 1
                            color: root.colors.accent

                            Behavior on height {
                                NumberAnimation { duration: 100 }
                            }
                        }
                    }
                }
            }
        }

        Rectangle {
            anchors.top: tabRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 1
            color: root.colors.surface2
        }

        Item {
            anchors.top: tabRow.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.topMargin: 1

            PowerTab {
                anchors.fill: parent
                anchors.margins: 8
                visible: root.activeTab === 0
                colors: root.colors
            }

            TimeTab {
                anchors.fill: parent
                anchors.margins: 8
                visible: root.activeTab === 1
                colors: root.colors
            }

            SysTab {
                anchors.fill: parent
                anchors.margins: 8
                visible: root.activeTab === 2
                colors: root.colors
            }
        }
    }

    MouseArea {
        id: hoverArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: {
            collapseTimer.stop()
            root.isExpanded = true
            root.activeTab = Math.floor(mouseX / width * 3)
        }

        onPositionChanged: {
            collapseTimer.stop()
            if (root.isExpanded && mouseY < tabRow.height)
                root.activeTab = Math.floor(mouseX / width * 3)
        }

        onExited: {
            collapseTimer.restart()
        }
    }

    Timer {
        id: collapseTimer
        interval: 400
        onTriggered: {
            if (!hoverArea.containsMouse)
                root.isExpanded = false
        }
    }
}
