import QtQuick
import Quickshell
import Quickshell.Wayland
import "../lib"

PanelWindow {
    id: root

    required property var colors

    property real collapsedHeight: 2
    property real expandedHeight: 180
    property real panelWidth: 520
    property bool isExpanded: false
    property int activeTab: 0

    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins {
        left: (root.screen.width - root.panelWidth) / 2
        right: (root.screen.width - root.panelWidth) / 2
    }

    color: "transparent"
    focusable: false
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    implicitHeight: root.isExpanded ? root.expandedHeight : root.collapsedHeight

    Behavior on implicitHeight {
        Anim { animType: "spatial" }
    }

    Rectangle {
        id: bg
        y: -12
        width: parent.width
        height: parent.height + 12
        radius: 12
        color: root.colors.background

        Behavior on color {
            CAnim {}
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

            Rectangle {
                id: tabIndicator
                anchors.bottom: parent.bottom
                width: parent.width / 3 * 0.4
                height: 2
                radius: 1
                color: root.colors.accent

                readonly property real tabW: parent.width / 3
                x: root.activeTab * tabW + (tabW - width) / 2

                Behavior on x {
                    NumberAnimation {
                        duration: 250
                        easing.type: Easing.Bezier
                        easing.bezierCurve: [0.38, 1.21, 0.22, 1.0]
                    }
                }
                Behavior on color { CAnim {} }
            }

            Row {
                anchors.fill: parent

                Repeater {
                    model: ["Profile", "Time", "System"]

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
                                CAnim {}
                            }
                        }

                        Item { width: 1; height: 1 }
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
                    opacity: root.activeTab === 0 ? 1 : 0
                    colors: root.colors
                    Behavior on opacity { Anim { animType: "effect" } }
                }

                TimeTab {
                    anchors.fill: parent
                    anchors.margins: 8
                    opacity: root.activeTab === 1 ? 1 : 0
                    colors: root.colors
                    Behavior on opacity { Anim { animType: "effect" } }
                }

                SysTab {
                    anchors.fill: parent
                    anchors.margins: 8
                    opacity: root.activeTab === 2 ? 1 : 0
                    colors: root.colors
                    Behavior on opacity { Anim { animType: "effect" } }
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
