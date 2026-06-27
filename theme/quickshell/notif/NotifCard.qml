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
        opacityAnim.from = 1
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
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                var defaultAction = null
                for (var i = 0; i < root.notifActions.length; i++) {
                    if (root.notifActions[i].identifier === "default") {
                        defaultAction = root.notifActions[i]
                        break
                    }
                }
                if (defaultAction) {
                    try { defaultAction.invoke() } catch (e) {}
                } else {
                    root.startExit()
                }
            }
            onEntered: { if (dismissTimer.running) dismissTimer.stop() }
            onExited: { if (!root.dismissing && dismissTimer.interval > 0) dismissTimer.restart() }
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
                            onEntered: { if (dismissTimer.running) dismissTimer.stop() }
                            onExited: { if (!root.dismissing && dismissTimer.interval > 0) dismissTimer.restart() }
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
