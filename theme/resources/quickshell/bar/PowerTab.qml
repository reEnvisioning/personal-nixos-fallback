import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var colors

    property string userName: "visionary"
    property string hostName: ""
    property string osName: ""
    property string kernelVer: ""
    property string cpuModel: ""
    property string uptimeStr: ""

    function refresh(): void {
        infoReader.running = false
        infoReader.running = true
    }

    function parseInfo(data: string): void {
        const lines = data.trim().split("\n")
        for (const line of lines) {
            const idx = line.indexOf("=")
            if (idx < 0) continue
            const key = line.slice(0, idx)
            const val = line.slice(idx + 1)
            if (key === "host") root.hostName = val
            else if (key === "os") root.osName = val
            else if (key === "kernel") root.kernelVer = val
            else if (key === "cpu") root.cpuModel = val
            else if (key === "uptime") root.uptimeStr = val
        }
    }

    Timer {
        interval: 60000; running: true; repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: infoReader
        command: ["sh", "-c",
            "echo host=$(hostname)"
            + "; echo os=$(awk -F= '/^PRETTY_NAME/{print $2}' /etc/os-release 2>/dev/null | tr -d '\"' | sed 's/ (.*)//')"
            + "; echo kernel=$(uname -r)"
            + "; echo cpu=$(grep -m1 'model name' /proc/cpuinfo | sed 's/.*: //' | sed 's/(R)//g; s/ CPU.*//')"
            + "; echo uptime=$(uptime -p | sed 's/up //')"
        ]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.parseInfo(text)
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 16
        width: parent.width - 16

        Item {
            width: 76
            height: 72

            Image {
                id: pfpLoader
                source: "../user/visionary.png"
                asynchronous: true
                onStatusChanged: if (status === Image.Ready) canvas.requestPaint()
            }

            Canvas {
                id: canvas
                anchors.centerIn: parent
                width: 72; height: 72

                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)

                    ctx.save()
                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, width / 2, 0, Math.PI * 2)
                    ctx.closePath()
                    ctx.clip()

                    ctx.drawImage("../user/visionary.png", 0, 0, width, height)
                    ctx.restore()

                    ctx.beginPath()
                    ctx.arc(width / 2, height / 2, width / 2 - 1, 0, Math.PI * 2)
                    ctx.strokeStyle = root.colors.accent
                    ctx.lineWidth = 2
                    ctx.stroke()
                }

                Connections {
                    target: root.colors
                    onAccentChanged: canvas.requestPaint()
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            Text {
                text: root.userName + "@" + (root.hostName.length > 0 ? root.hostName : "...")
                color: root.colors.text
                font.pointSize: 12
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Rectangle {
                width: parent.width; height: 1
                color: root.colors.surface2
                Layout.bottomMargin: 2
            }

            RowLayout {
                spacing: 4
                Text { text: "OS"; color: root.colors.subtext0; font.pointSize: 9; font.weight: Font.DemiBold }
                Text { text: root.osName; color: root.colors.text; font.pointSize: 9; elide: Text.ElideRight }
            }
            RowLayout {
                spacing: 4
                Text { text: "Kernel"; color: root.colors.subtext0; font.pointSize: 9; font.weight: Font.DemiBold }
                Text { text: root.kernelVer; color: root.colors.text; font.pointSize: 9; elide: Text.ElideRight }
            }
            RowLayout {
                spacing: 4
                Text { text: "Uptime"; color: root.colors.subtext0; font.pointSize: 9; font.weight: Font.DemiBold }
                Text { text: root.uptimeStr; color: root.colors.text; font.pointSize: 9; elide: Text.ElideRight }
            }
            RowLayout {
                spacing: 4
                Text { text: "Theme"; color: root.colors.subtext0; font.pointSize: 9; font.weight: Font.DemiBold }
                Text { text: root.colors.themeName; color: root.colors.text; font.pointSize: 9; font.weight: Font.DemiBold; elide: Text.ElideRight }
            }
        }
    }
}
