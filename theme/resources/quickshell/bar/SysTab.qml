import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root

    required property var colors

    property real diskPct: 0
    property string diskUsed: ""
    property string diskTotal: ""
    property real memPct: 0
    property string memUsed: ""
    property string memTotal: ""
    property real cpuPct: 0

    property var prevCpu: ({ idle: 0, total: 0 })

    function parseCpu(line: string): void {
        const parts = line.trim().split(/\s+/)
        if (parts[0] !== "cpu") return
        const idle = parseInt(parts[4])
        const total = parts.slice(1).reduce((a, b) => a + parseInt(b), 0)
        const dIdle = idle - root.prevCpu.idle
        const dTotal = total - root.prevCpu.total
        root.cpuPct = dTotal > 0 ? Math.round((1 - dIdle / dTotal) * 100) : 0
        root.prevCpu = { idle, total }
    }

    function refresh(): void {
        diskReader.running = false; diskReader.running = true
        memReader.running = false; memReader.running = true
        cpuReader.running = false; cpuReader.running = true
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: root.refresh()
    }

    Process {
        id: diskReader
        command: ["df", "--output=pcent,used,size", "/"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split("\n")
                if (lines.length < 2) return
                const parts = lines[1].trim().split(/\s+/)
                if (parts.length >= 3) {
                    root.diskPct = parseInt(parts[0]) || 0
                    root.diskUsed = parts[1]
                    root.diskTotal = parts[2]
                }
            }
        }
    }

    Process {
        id: memReader
        command: ["sh", "-c", "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%d %d %d\", t-a, t, (t-a)*100/t}' /proc/meminfo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split(" ")
                if (parts.length >= 3) {
                    const used = parseInt(parts[0])
                    const total = parseInt(parts[1])
                    root.memUsed = (used / 1048576).toFixed(1) + "G"
                    root.memTotal = (total / 1048576).toFixed(1) + "G"
                    root.memPct = parseInt(parts[2])
                }
            }
        }
    }

    Process {
        id: cpuReader
        command: ["sh", "-c", "head -n1 /proc/stat"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.parseCpu(text.trim())
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10
        width: 200

        RowLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "Disk"; color: root.colors.subtext0; font.pointSize: 10 }
            Item { Layout.fillWidth: true }
            Text { text: root.diskUsed + " / " + root.diskTotal; color: root.colors.text; font.pointSize: 10 }
        }
        Rectangle {
            Layout.fillWidth: true; height: 8; radius: 4; color: root.colors.surface2
            Rectangle {
                width: parent.width * root.diskPct / 100; height: parent.height; radius: 4
                color: root.colors.blue
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "RAM"; color: root.colors.subtext0; font.pointSize: 10 }
            Item { Layout.fillWidth: true }
            Text { text: root.memUsed + " / " + root.memTotal; color: root.colors.text; font.pointSize: 10 }
        }
        Rectangle {
            Layout.fillWidth: true; height: 8; radius: 4; color: root.colors.surface2
            Rectangle {
                width: parent.width * root.memPct / 100; height: parent.height; radius: 4
                color: root.colors.green
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }

        RowLayout {
            Layout.fillWidth: true; spacing: 4
            Text { text: "CPU"; color: root.colors.subtext0; font.pointSize: 10 }
            Item { Layout.fillWidth: true }
            Text { text: root.cpuPct + "%"; color: root.colors.text; font.pointSize: 10 }
        }
        Rectangle {
            Layout.fillWidth: true; height: 8; radius: 4; color: root.colors.surface2
            Rectangle {
                width: parent.width * root.cpuPct / 100; height: parent.height; radius: 4
                color: root.colors.magenta
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
            }
        }
    }
}
