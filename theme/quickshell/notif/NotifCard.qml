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
    property bool isReusable: false
    property bool reused: false

    function updateFrom(notification) {
        reused = true
        try {
            var n = notification
            notifSummary = n.summary || ""
            notifBody = n.body || ""
            notifAppName = n.appName || ""
            notifUrgency = typeof n.urgency === "number" ? n.urgency : 1
            notifExpireTimeout = typeof n.expireTimeout === "number" ? n.expireTimeout : -1
            notifHasImage = !!n.image
            if (n.actions) notifActions = n.actions
        } catch (e) {
            console.log("NotifCard: update error", e)
        }
        dismissTimer.restart()
    }

    property string notifSummary: ""
    property string notifBody: ""
    property string notifAppName: ""
    property int notifUrgency: 1
    property var notifActions: []
    property bool notifHasImage: false
    property int notifExpireTimeout: -1

    width: parent ? parent.width : 380
    height: card.height

    x: 0
    opacity: 0
    property real cardScale: 0.5
    property real slideOffset: 40

    transform: [
        Scale { origin.x: width; origin.y: 0; xScale: root.cardScale; yScale: root.cardScale },
        Translate { x: root.slideOffset }
    ]

    Anim { id: animX; target: root; property: "x" }
    Anim { id: cardScaleAnim; target: root; property: "cardScale" }
    Anim { id: slideAnim; target: root; property: "slideOffset" }
    Anim { id: opacityAnim; target: root; property: "opacity" }

    Component.onCompleted: {
        cardScaleAnim.stop()
        cardScaleAnim.from = 0.5
        cardScaleAnim.to = 1.0
        cardScaleAnim.type = Anim.Emphasized
        cardScaleAnim.start()

        slideAnim.stop()
        slideAnim.from = 40
        slideAnim.to = 0
        slideAnim.type = Anim.SpatialDefault
        slideAnim.start()

        opacityAnim.stop()
        opacityAnim.from = 0
        opacityAnim.to = 1
        opacityAnim.type = Anim.EffectsSlow
        opacityAnim.start()
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
        function onClosed() { if (!root.reused) root.startExit() }
    }

    function startExit() {
        if (root.dismissing) return
        root.dismissing = true

        cardScaleAnim.stop()
        cardScaleAnim.from = root.cardScale
        cardScaleAnim.to = 0.7
        cardScaleAnim.type = Anim.StandardAccel
        cardScaleAnim.start()

        slideAnim.stop()
        slideAnim.from = root.slideOffset
        slideAnim.to = 80
        slideAnim.type = Anim.StandardAccel
        slideAnim.start()

        opacityAnim.stop()
        opacityAnim.from = root.opacity
        opacityAnim.to = 0
        opacityAnim.type = Anim.StandardAccel
        opacityAnim.start()

        exitTimer.start()
        try { root.notif.dismiss() } catch (e) {}
    }

    Timer {
        id: exitTimer
        interval: 500
        onTriggered: {
            root.visible = false
            root.dismissed()
        }
    }

    // Stretch glow behind card
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        width: parent.width * 1.3
        height: parent.height * 1.3
        radius: width * 0.5
        color: Qt.rgba(1, 1, 1, 0.035)
        opacity: root.opacity * 0.5
        visible: opacity > 0.01
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
            Behavior on opacity { Anim { type: Anim.EffectsDefault } }
        }

        MouseArea {
            id: swipeArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton

            property real startX: 0

            onEntered: dismissTimer.stop()
            onExited: {
                if (!pressed)
                    dismissTimer.restart()
            }

            onPressed: event => {
                dismissTimer.stop()
                startX = event.x
                if (event.button === Qt.MiddleButton)
                    root.startExit()
            }

            onReleased: event => {
                if (root.dismissing) return

                if (!containsMouse)
                    dismissTimer.restart()

                if (Math.abs(root.x) < root.implicitWidth * 0.3) {
                    root.opacity = 1
                    animX.stop()
                    animX.from = root.x
                    animX.to = 0
                    animX.type = Anim.EmphasizedDecel
                    animX.start()
                } else {
                    root.startExit()
                }
            }

            onPositionChanged: event => {
                if (pressed && !root.dismissing) {
                    var dx = event.x - startX
                    root.x = dx
                    var progress = Math.abs(dx) / (root.implicitWidth * 0.7)
                    root.opacity = Math.max(0, 1 - progress)
                }
            }

            onClicked: event => {
                if (event.button !== Qt.LeftButton || root.dismissing) return
                if (root.notifActions.length === 1) {
                    try { root.notifActions[0].invoke() } catch (e) {}
                }
            }
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
                visible: false
                layoutDirection: Qt.RightToLeft

                Repeater {
                    model: root.notifActions

                    delegate: Rectangle {
                        required property var modelData

                        id: actionBtn
                        height: Math.round(26 * root.uiScale)
                        radius: Math.round(8 * root.uiScale)
                        color: actionBtnMouse.containsMouse ? root.colors.highlighted : root.colors.surface2
                        implicitWidth: actionLabel.width + Math.round(14 * root.uiScale)

                        Behavior on color { CAnim {} }

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            color: root.colors.text
                            font.pointSize: 9
                        }

                        MouseArea {
                            id: actionBtnMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                try { modelData.invoke() } catch (e) {}
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
    }
}
