import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../lib"

Item {
    id: root

    required property var colors

    property string userName: "user"

    Process {
        id: userReader
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.userName = text.trim()
        }
    }
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

        Rectangle {
            id: pfpFrame
            Layout.leftMargin: 35
            width: 72; height: 72; radius: 36
            clip: true
            color: "transparent"
            border.width: 2
            border.color: root.colors.accent
            Behavior on border.color { CAnim {} }

            Image {
                anchors.centerIn: parent
                width: 68; height: 68
                sourceSize { width: 68; height: 68 }
                source: "../../resources/user/" + root.userName + ".png"
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
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
                Text { text: root.colors.themeName; color: root.colors.text; font.pointSize: 9; elide: Text.ElideRight }
            }
        }
    }
}
