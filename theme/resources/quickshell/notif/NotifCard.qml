import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import "../lib"

Item {
    id: root

    required property var notif
    required property var colors
    required property real uiScale

    signal dismissed()

    property bool dismissing: false

    // Local copies — safe access, avoids crash reading raw Notification props
    property string notifSummary: ""
    property string notifBody: ""
    property string notifAppName: ""
    property int notifUrgency: 1
    property var notifActions: []
    property bool notifHasImage: false
    property int notifExpireTimeout: -1

    width: parent ? parent.width : 380
    height: card.height

    x: parent ? parent.width : Math.round(380 * root.uiScale)
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

    Component.onCompleted: {
        x = 0
        opacity = 1
        try {
            var n = root.notif
            notifSummary = n.summary || ""
            notifBody = n.body || ""
            notifAppName = n.appName || ""
            notifUrgency = typeof n.urgency === "number" ? n.urgency : 1
            notifExpireTimeout = typeof n.expireTimeout === "number" ? n.expireTimeout : -1
            notifHasImage = !!n.image
            if (n.actions) notifActions = n.actions
        } catch (e) {
            console.log("NotifCard: copy error", e)
        }
    }

    Connections {
        target: root.notif
        function onClosed() { root.startExit() }
    }

    function startExit() {
        if (root.dismissing) return
        root.dismissing = true
        height = 0
        visible = false
        x = Math.round(380 * root.uiScale)
        opacity = 0
        hideTimer.start()
        try { root.notif.dismiss() } catch (e) {}
    }

    Timer {
        id: hideTimer
        interval: 350
        onTriggered: root.dismissed()
    }

    Rectangle {
        id: card
        width: parent.width
        height: innerLayout.height + Math.round(16 * root.uiScale)
        radius: Math.round(12 * root.uiScale)
        color: root.colors.background
        clip: true

        Behavior on color { CAnim {} }

        // Critical urgency subtle tint
        Rectangle {
            anchors.fill: parent
            radius: Math.round(12 * root.uiScale)
            color: root.colors.red
            opacity: root.notifUrgency === 2 ? 0.08 : 0
            Behavior on opacity { NumberAnimation { duration: 200 } }
        }

        ColumnLayout {
            id: innerLayout
            x: Math.round(12 * root.uiScale); y: Math.round(8 * root.uiScale)
            width: parent.width - Math.round(24 * root.uiScale)
            spacing: Math.round(4 * root.uiScale)

            Text {
                Layout.fillWidth: true
                text: root.notifSummary
                color: root.colors.text
                font.pointSize: 10
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            Text {
                Layout.fillWidth: true
                text: root.notifBody
                color: root.colors.subtext1
                font.pointSize: 9
                wrapMode: Text.WordWrap
                maximumLineCount: 3
                elide: Text.ElideRight
                visible: root.notifBody !== ""
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.maximumHeight: Math.round(180 * root.uiScale)
                radius: Math.round(8 * root.uiScale)
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
                visible: root.notifActions.length > 0
                layoutDirection: Qt.RightToLeft

                Repeater {
                    model: root.notifActions

                    delegate: Rectangle {
                        required property var modelData

                        id: actionBtn
                        height: Math.round(24 * root.uiScale)
                        radius: Math.round(6 * root.uiScale)
                        color: actionArea.containsMouse ? root.colors.highlighted : root.colors.surface2
                        implicitWidth: actionLabel.width + Math.round(12 * root.uiScale)

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
                                try { modelData.invoke() } catch (e) {}
                                root.startExit()
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: dismissTimer
            interval: {
                if (root.notifExpireTimeout > 0)
                    return root.notifExpireTimeout
                if (root.notifUrgency === 0) return 5000
                if (root.notifUrgency === 2) return 0
                return 7000
            }
            running: interval > 0 && !root.dismissing
            repeat: false
            onTriggered: root.startExit()
        }

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: { if (dismissTimer.running) dismissTimer.stop() }
            onExited: { if (!root.dismissing && dismissTimer.interval > 0) dismissTimer.restart() }
        }
    }
}
