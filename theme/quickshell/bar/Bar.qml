import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../lib"

PanelWindow {
    id: root

    required property var colors

    required property real uiScale

    property real collapsedHeight: Math.round(2 * root.uiScale)
    property real expandedHeight: Math.round(180 * root.uiScale)
    property real panelWidth: Math.round(520 * root.uiScale)
    property bool isExpanded: false
    property int activeTab: 0
    property real animHeight: root.collapsedHeight
    property bool dndActive: false
    property string proxyStatus: "disabled"
    property string idleStatus: "unknown"

    onIsExpandedChanged: {
        expandAnim.stop()
        expandAnim.from = root.animHeight
        expandAnim.to = root.isExpanded ? root.expandedHeight : root.collapsedHeight
        expandAnim.duration = root.isExpanded ? 350 : 150
        expandAnim.easing.type = root.isExpanded ? Easing.Bezier : Easing.OutQuad
        if (root.isExpanded)
            expandAnim.easing.bezierCurve = [0.34, 1.56, 0.25, 1.0]
        expandAnim.start()
    }

    NumberAnimation {
        id: expandAnim
        target: root
        property: "animHeight"
    }

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

    implicitHeight: root.animHeight

    Rectangle {
        id: bg
        y: Math.round(-12 * root.uiScale)
        width: parent.width
        height: parent.height + Math.round(12 * root.uiScale)
        radius: Math.round(12 * root.uiScale)
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
            height: Math.round(26 * root.uiScale)

            Rectangle {
                id: tabIndicator
                anchors.bottom: parent.bottom
                width: parent.width / 3 * 0.4
                height: Math.round(2 * root.uiScale)
                radius: Math.round(1 * root.uiScale)
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
                    model: ["Home", "States", "Monitor"]

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

                        Item { implicitWidth: 1; implicitHeight: 1 }
                    }
                }
            }
        }

            Rectangle {
                anchors.top: tabRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.round(1 * root.uiScale)
                color: root.colors.surface2
            }

            Item {
                anchors.top: tabRow.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.topMargin: Math.round(1 * root.uiScale)

                HomeTab {
                    anchors.fill: parent
                    anchors.margins: Math.round(8 * root.uiScale)
                    opacity: root.activeTab === 0 ? 1 : 0
                    colors: root.colors
                    Behavior on opacity { Anim { animType: "effect" } }
                }

                StatesTab {
                    anchors.fill: parent
                    anchors.margins: Math.round(8 * root.uiScale)
                    opacity: root.activeTab === 1 ? 1 : 0
                    colors: root.colors
                    dndActive: root.dndActive
                    proxyStatus: root.proxyStatus
                    idleStatus: root.idleStatus
                    Behavior on opacity { Anim { animType: "effect" } }
                }

                MonitorTab {
                    anchors.fill: parent
                    anchors.margins: Math.round(8 * root.uiScale)
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
            autoCollapseTimer.stop()
            collapseTimer.stop()
            root.activeTab = Math.floor(mouseX / width * 3)
            root.isExpanded = true
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

    Timer {
        id: autoCollapseTimer
        interval: 3000
        onTriggered: root.isExpanded = false
    }

    function activateTab(index: int): void {
        if (index >= 0 && index <= 2) {
            root.activeTab = index
            root.isExpanded = true
            autoCollapseTimer.restart()
        }
    }
}
