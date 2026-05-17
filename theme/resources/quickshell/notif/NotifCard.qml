import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../lib"

Item {
    id: root

    required property var notif
    required property var colors

    signal dismissed()

    property bool dismissing: false

    width: parent ? parent.width : 380
    height: card.height

    x: parent ? parent.width : 400
    opacity: 0

    Behavior on x {
        NumberAnimation {
            duration: 300
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.34, 1.56, 0.25, 1.0]
        }
    }
    Behavior on opacity {
        NumberAnimation {
            duration: 200
            easing.type: Easing.Bezier
            easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
        }
    }

    Component.onCompleted: { x = 0; opacity = 1 }

    function startExit() {
        if (root.dismissing) return
        root.dismissing = true
        hideTimer.stop()
        x = 400
        opacity = 0
    }

    Connections {
        target: root.notif
        function onClosed() { root.startExit() }
    }

    Timer {
        id: hideTimer
        interval: 350
        onTriggered: root.dismissed()
    }

    Rectangle {
        id: card
        width: parent.width
        height: innerLayout.height + 16
        radius: 12
        color: root.colors.background
        clip: true

        Behavior on color { CAnim {} }

        Rectangle {
            x: 0; y: 0
            width: 2; height: parent.height
            radius: 1
            color: {
                const u = root.notif.urgency.toString()
                if (u === "Low")      return root.colors.green
                if (u === "Critical") return root.colors.red
                return root.colors.accent
            }
            Behavior on color { CAnim {} }
        }

        RowLayout {
            id: innerLayout
            x: 8; y: 8
            width: parent.width - 16
            spacing: 10

            Rectangle {
                id: iconFrame
                width: 36; height: 36; radius: 8
                color: root.colors.surface2
                visible: root.notif.appIcon !== "" || root.notif.appName !== ""
                clip: true

                Image {
                    id: iconImg
                    anchors.fill: parent
                    source: root.notif.appIcon
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: root.notif.appName.length > 0 ? root.notif.appName.charAt(0).toUpperCase() : "?"
                    color: root.colors.text
                    font.pointSize: 14
                    font.weight: Font.DemiBold
                    visible: iconImg.status !== Image.Ready
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 3

                Item {
                    Layout.fillWidth: true
                    height: Math.max(summaryText.height, closeBtn.height)

                    Text {
                        id: summaryText
                        anchors.left: parent.left
                        anchors.right: closeBtn.left
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.notif.summary
                        color: root.colors.text
                        font.pointSize: 10
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                        maximumLineCount: 1
                    }

                    Rectangle {
                        id: closeBtn
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 18; height: 18; radius: 9
                        color: closeBtnArea.containsMouse ? root.colors.highlighted : root.colors.surface2

                        Text {
                            anchors.centerIn: parent
                            text: "\u00D7"
                            color: root.colors.subtext0
                            font.pointSize: 12
                        }

                        MouseArea {
                            id: closeBtnArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.notif.dismiss()
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.notif.body
                    color: root.colors.subtext1
                    font.pointSize: 9
                    wrapMode: Text.WordWrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: root.notif.body !== ""
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.maximumHeight: 200
                    radius: 8
                    color: root.colors.surface2
                    clip: true
                    visible: notifImg.status === Image.Ready

                    Image {
                        id: notifImg
                        anchors.fill: parent
                        source: root.notif.image
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                }

                Row {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: root.notif.actions.length > 0
                    layoutDirection: Qt.RightToLeft

                    Repeater {
                        model: root.notif.actions

                        delegate: Rectangle {
                            required property var modelData

                            id: actionBtn
                            height: 24
                            radius: 6
                            color: actionArea.containsMouse ? root.colors.highlighted : root.colors.surface2
                            implicitWidth: actionLabel.width + 12

                            Text {
                                id: actionLabel
                                anchors.centerIn: parent
                                text: modelData.text
                                color: root.colors.text
                                font.pointSize: 9
                            }

                            MouseArea {
                                id: actionArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    modelData.invoke()
                                    root.notif.dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: dismissTimer
            interval: {
                if (root.notif.expireTimeout >= 0 && root.notif.expireTimeout !== 0)
                    return root.notif.expireTimeout

                const u = root.notif.urgency.toString()
                if (u === "Low")      return 5000
                if (u === "Critical") return 0
                return 7000
            }
            running: interval > 0 && !root.dismissing
            repeat: false
            onTriggered: root.notif.dismiss()
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { if (dismissTimer.running) dismissTimer.stop() }
            onExited: { if (!root.dismissing && dismissTimer.interval > 0) dismissTimer.restart() }
        }
    }
}
