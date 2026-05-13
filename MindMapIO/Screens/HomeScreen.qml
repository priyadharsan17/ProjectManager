import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

Rectangle {
    id: root
    anchors.fill: parent
    color: theme.rootBackground

    // Inline theme object
    QtObject {
        id: theme
        property color rootBackground: "#050510"
        property color backgroundGradient0: "#0a0020"
        property color backgroundGradient1: "#060618"
        property color backgroundGradient2: "#02020e"
        property color containerBackground: Qt.rgba(0.04, 0.04, 0.12, 0.92)
        property color containerBorder: Qt.rgba(0.2, 0.4, 0.9, 0.3)
        property color containerOverlay: Qt.rgba(0.07, 0.07, 0.2, 0.7)
        property color primary: "#00d4ff"
        property color primaryAlt: "#7b2fff"
        property color primaryGlow: "#0088aa"
        property color accent: "#ff2d78"
        property color textPrimary: "#e0f4ff"
        property color textSecondary: "#6aa3c8"
        property color textMuted: "#3a607a"
        property color error: "#ff2d78"
        property color success: "#10e898"
    }

    // ── Animated starfield background ──────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: theme.backgroundGradient2 }
            GradientStop { position: 0.5; color: theme.backgroundGradient1 }
            GradientStop { position: 1.0; color: theme.backgroundGradient0 }
        }
    }

    Canvas {
        id: starCanvas
        anchors.fill: parent
        property var stars: []

        Component.onCompleted: {
            var s = []
            for (var i = 0; i < 120; i++) {
                s.push({
                    x: Math.random() * width,
                    y: Math.random() * height,
                    r: Math.random() * 1.5 + 0.3,
                    a: Math.random()
                })
            }
            stars = s
            requestPaint()
        }

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            for (var i = 0; i < stars.length; i++) {
                var s = stars[i]
                ctx.beginPath()
                ctx.arc(s.x, s.y, s.r, 0, 2 * Math.PI)
                ctx.fillStyle = "rgba(150,210,255," + s.a + ")"
                ctx.fill()
            }
        }
    }

    // Glow orbs
    Rectangle {
        width: 500; height: 500; radius: 250
        x: -100; y: -150
        opacity: 0.06
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.primary }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    Rectangle {
        width: 400; height: 400; radius: 200
        x: parent.width - 250; y: parent.height - 300
        opacity: 0.07
        gradient: Gradient {
            GradientStop { position: 0.0; color: theme.primaryAlt }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // ── Center card ───────────────────────────────────────────────────────
    Rectangle {
        anchors.centerIn: parent
        width: 460
        height: 540
        radius: 20
        color: theme.containerBackground
        border.color: theme.containerBorder
        border.width: 1

        // Glowing border effect
        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            radius: parent.radius + 1
            color: "transparent"
            border.color: Qt.rgba(0, 0.83, 1.0, 0.25)
            border.width: 1
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 40
            spacing: 32

            // Logo / Title
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                // Hexagonal logo icon
                Canvas {
                    Layout.alignment: Qt.AlignHCenter
                    width: 64; height: 64
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var cx = width / 2, cy = height / 2, r = 28
                        ctx.beginPath()
                        for (var i = 0; i < 6; i++) {
                            var a = Math.PI / 180 * (60 * i - 30)
                            var px = cx + r * Math.cos(a)
                            var py = cy + r * Math.sin(a)
                            if (i === 0) ctx.moveTo(px, py); else ctx.lineTo(px, py)
                        }
                        ctx.closePath()
                        var grad = ctx.createLinearGradient(0, 0, width, height)
                        grad.addColorStop(0, "#00d4ff")
                        grad.addColorStop(1, "#7b2fff")
                        ctx.strokeStyle = grad
                        ctx.lineWidth = 2.5
                        ctx.stroke()

                        // Inner dot
                        ctx.beginPath()
                        ctx.arc(cx, cy, 5, 0, 2 * Math.PI)
                        ctx.fillStyle = "#00d4ff"
                        ctx.fill()

                        // Spokes
                        var spokes = [0, 2, 4]
                        for (var j = 0; j < spokes.length; j++) {
                            var sa = Math.PI / 180 * (60 * spokes[j] - 30)
                            ctx.beginPath()
                            ctx.moveTo(cx, cy)
                            ctx.lineTo(cx + (r - 5) * Math.cos(sa), cy + (r - 5) * Math.sin(sa))
                            ctx.strokeStyle = "#00d4ffaa"
                            ctx.lineWidth = 1.5
                            ctx.stroke()
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "MINDMAP IO"
                    font.pixelSize: 26
                    font.bold: true
                    font.letterSpacing: 6
                    color: theme.textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "NEURAL MAPPING SYSTEM"
                    font.pixelSize: 10
                    font.letterSpacing: 3
                    color: theme.textSecondary
                }
            }

            // Divider
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: theme.containerBorder
            }

            // Buttons
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 16

                // ── Create New Map button ─────────────────────────────────
                Rectangle {
                    id: createBtn
                    Layout.fillWidth: true
                    height: 52
                    radius: 10
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: theme.primary }
                        GradientStop { position: 1.0; color: theme.primaryAlt }
                    }
                    scale: createHover.containsMouse ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    // Glow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -3
                        radius: parent.radius + 3
                        color: "transparent"
                        border.color: Qt.rgba(0, 0.83, 1.0, createHover.containsMouse ? 0.5 : 0.0)
                        border.width: 2
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "⬡"
                            font.pixelSize: 18
                            color: "white"
                        }
                        Text {
                            text: "CREATE NEW MAP"
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 2
                            color: "white"
                        }
                    }

                    HoverHandler { id: createHover }
                    TapHandler {
                        onTapped: newMapDialog.open()
                    }
                }

                // ── Open Existing Map button ──────────────────────────────
                Rectangle {
                    id: openBtn
                    Layout.fillWidth: true
                    height: 52
                    radius: 10
                    color: "transparent"
                    border.color: Qt.rgba(0, 0.83, 1.0, openHover.containsMouse ? 0.8 : 0.4)
                    border.width: 1.5
                    Behavior on border.color { ColorAnimation { duration: 150 } }
                    scale: openHover.containsMouse ? 1.02 : 1.0
                    Behavior on scale { NumberAnimation { duration: 120 } }

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 10

                        Text {
                            text: "◈"
                            font.pixelSize: 18
                            color: theme.primary
                        }
                        Text {
                            text: "OPEN EXISTING MAP"
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 2
                            color: theme.primary
                        }
                    }

                    HoverHandler { id: openHover }
                    TapHandler {
                        onTapped: openFileDialog.open()
                    }
                }
            }

            // Error message
            Text {
                id: errorText
                Layout.fillWidth: true
                visible: text.length > 0
                text: ""
                color: theme.error
                font.pixelSize: 12
                wrapMode: Text.Wrap
                horizontalAlignment: Text.AlignHCenter
            }

            Item { Layout.fillHeight: true }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "SCI-FI NEURAL NETWORK VISUALIZER"
                font.pixelSize: 9
                font.letterSpacing: 2
                color: theme.textMuted
            }
        }
    }

    // ── New Map Dialog ─────────────────────────────────────────────────────
    Rectangle {
        id: newMapDialog
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.7)
        visible: false
        z: 100

        function open() { visible = true; mapTitleInput.text = ""; mapTitleInput.forceActiveFocus() }
        function close() { visible = false }

        Rectangle {
            anchors.centerIn: parent
            width: 400
            height: 280
            radius: 16
            color: "#090920"
            border.color: Qt.rgba(0, 0.83, 1.0, 0.4)
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 20

                Text {
                    text: "INITIALISE NEW MAP"
                    font.pixelSize: 16
                    font.bold: true
                    font.letterSpacing: 3
                    color: theme.textPrimary
                    Layout.alignment: Qt.AlignHCenter
                }

                // Title input
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    Text { text: "MAP TITLE"; font.pixelSize: 10; font.letterSpacing: 2; color: theme.textSecondary }
                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 8
                        color: Qt.rgba(0.05, 0.05, 0.15, 1)
                        border.color: mapTitleInput.activeFocus ? theme.primary : theme.containerBorder
                        border.width: 1

                        TextInput {
                            id: mapTitleInput
                            anchors {
                                left: parent.left; leftMargin: 12
                                right: parent.right; rightMargin: 12
                                verticalCenter: parent.verticalCenter
                            }
                            color: theme.textPrimary
                            font.pixelSize: 14
                            clip: true
                            text: "My MindMap"
                        }
                    }
                }

                // Buttons row
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 8
                        color: "transparent"
                        border.color: theme.containerBorder
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "CANCEL"
                            font.pixelSize: 12
                            font.letterSpacing: 2
                            color: theme.textSecondary
                        }
                        TapHandler { onTapped: newMapDialog.close() }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 40
                        radius: 8
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: theme.primary }
                            GradientStop { position: 1.0; color: theme.primaryAlt }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "CHOOSE LOCATION"
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 1
                            color: "white"
                        }
                        TapHandler {
                            onTapped: {
                                pendingTitle = mapTitleInput.text
                                saveFileDialog.open()
                                newMapDialog.close()
                            }
                        }
                    }
                }
            }
        }
    }

    property string pendingTitle: ""

    // ── File Dialogs ───────────────────────────────────────────────────────
    FileDialog {
        id: saveFileDialog
        title: "Save MindMap As..."
        fileMode: FileDialog.SaveFile
        nameFilters: ["MindMap JSON (*.json)", "All Files (*)"]
        defaultSuffix: "json"
        onAccepted: {
            var path = selectedFile.toString().replace("file:///", "").replace(/\//g, "\\")
            mindMapManager.createNewMap(path, pendingTitle)
        }
    }

    FileDialog {
        id: openFileDialog
        title: "Open MindMap..."
        fileMode: FileDialog.OpenFile
        nameFilters: ["MindMap JSON (*.json)", "All Files (*)"]
        onAccepted: {
            var path = selectedFile.toString().replace("file:///", "").replace(/\//g, "\\")
            mindMapManager.openMap(path)
        }
    }

    // Watch for map loaded
    Connections {
        target: mindMapManager
        function onMapLoadedChanged() {
            if (mindMapManager.mapLoaded) {
                window.navigate("MindMapCanvas")
            }
        }
        function onErrorOccurred(msg) {
            errorText.text = msg
            errorClearTimer.restart()
        }
    }

    Timer {
        id: errorClearTimer
        interval: 4000
        onTriggered: errorText.text = ""
    }
}
