import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    anchors.fill: parent
    color: "#04040f"

    // ── Inline theme ───────────────────────────────────────────────────────
    QtObject {
        id: theme
        property color primary:     "#00d4ff"
        property color primaryAlt:  "#7b2fff"
        property color accent:      "#ff2d78"
        property color textPrimary: "#e0f4ff"
        property color textSecondary:"#6aa3c8"
        property color textMuted:   "#3a607a"
        property color gridLine:    Qt.rgba(0.1, 0.3, 0.6, 0.18)
        property color edgeLine:    Qt.rgba(0.0, 0.83, 1.0, 0.55)
        property color containerBorder: Qt.rgba(0.2, 0.4, 0.9, 0.35)
        property color containerBg: Qt.rgba(0.04, 0.04, 0.14, 0.94)
        property var levelColors: ["#00d4ff","#7b2fff","#ff2d78","#10e898","#ffb800","#ff6b35"]
    }

    // ── Animated grid background ───────────────────────────────────────────
    Canvas {
        id: gridCanvas
        anchors.fill: parent
        property real offsetX: 0
        property real offsetY: 0

        NumberAnimation on offsetX { from: 0; to: 60; duration: 8000; loops: Animation.Infinite }
        NumberAnimation on offsetY { from: 0; to: 60; duration: 11000; loops: Animation.Infinite }

        onOffsetXChanged: requestPaint()
        onOffsetYChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            ctx.strokeStyle = "rgba(25,75,155,0.18)"
            ctx.lineWidth = 0.7
            var step = 60
            var sx = offsetX % step
            var sy = offsetY % step
            for (var x = sx - step; x < width + step; x += step) {
                ctx.beginPath(); ctx.moveTo(x, 0); ctx.lineTo(x, height); ctx.stroke()
            }
            for (var y = sy - step; y < height + step; y += step) {
                ctx.beginPath(); ctx.moveTo(0, y); ctx.lineTo(width, y); ctx.stroke()
            }
        }
    }

    // ── Top bar ────────────────────────────────────────────────────────────
    Rectangle {
        id: topBar
        anchors { top: parent.top; left: parent.left; right: parent.right }
        height: 56
        color: Qt.rgba(0.02, 0.02, 0.1, 0.9)
        border.color: Qt.rgba(0.2, 0.4, 0.9, 0.3)
        border.width: 1
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            // Back button
            Rectangle {
                width: 36; height: 36; radius: 8
                color: backHover.containsMouse ? Qt.rgba(0, 0.83, 1.0, 0.15) : "transparent"
                border.color: Qt.rgba(0, 0.83, 1.0, 0.4); border.width: 1
                HoverHandler { id: backHover }
                TapHandler { onTapped: window.navigate("HomeScreen") }
                Text { anchors.centerIn: parent; text: "←"; font.pixelSize: 18; color: theme.primary }
            }

            // Title
            Text {
                text: (mindMapManager.mapTitle || "MindMap").toUpperCase()
                font.pixelSize: 15; font.bold: true; font.letterSpacing: 3
                color: theme.textPrimary
                Layout.leftMargin: 12
            }

            Item { Layout.fillWidth: true }

            // Save indicator
            Text {
                id: saveIndicator
                text: "● SAVED"
                font.pixelSize: 10; font.letterSpacing: 2
                color: theme.primary
                opacity: 0.6
            }

            // Reset view button
            Rectangle {
                width: 90; height: 32; radius: 8; Layout.leftMargin: 12
                color: resetHover.containsMouse ? Qt.rgba(0, 0.83, 1.0, 0.1) : "transparent"
                border.color: Qt.rgba(0, 0.83, 1.0, 0.4); border.width: 1
                HoverHandler { id: resetHover }
                Text { anchors.centerIn: parent; text: "RESET VIEW"; font.pixelSize: 10; font.letterSpacing: 1; color: theme.primary }
                TapHandler {
                    onTapped: {
                        canvasFlickable.contentX = 0
                        canvasFlickable.contentY = 0
                        zoomScale = 1.0
                    }
                }
            }
        }
    }

    // ── Canvas area ────────────────────────────────────────────────────────
    property real zoomScale: 1.0
    property real minZoom: 0.3
    property real maxZoom: 3.0

    Flickable {
        id: canvasFlickable
        anchors { top: topBar.bottom; left: parent.left; right: parent.right; bottom: parent.bottom }
        contentWidth: canvasRoot.width * zoomScale
        contentHeight: canvasRoot.height * zoomScale
        clip: true
        interactive: !isDraggingNode

        WheelHandler {
            onWheel: {
                var factor = event.angleDelta.y > 0 ? 1.12 : 0.89
                var newZ = Math.max(root.minZoom, Math.min(root.maxZoom, root.zoomScale * factor))
                root.zoomScale = newZ
            }
        }

        Item {
            id: canvasRoot
            width: 3200
            height: 2400
            transformOrigin: Item.TopLeft
            scale: zoomScale

            // ── Edge drawing canvas ────────────────────────────────────────
            Canvas {
                id: edgeCanvas
                anchors.fill: parent
                z: 0

                function repaint() { requestPaint() }

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    var edges = mindMapManager.edges
                    var nodes = mindMapManager.nodes
                    if (!edges || !nodes) return

                    for (var i = 0; i < edges.length; i++) {
                        var e = edges[i]
                        var src = null, dst = null
                        for (var j = 0; j < nodes.length; j++) {
                            if (nodes[j].id === e.source) src = nodes[j]
                            if (nodes[j].id === e.target) dst = nodes[j]
                        }
                        if (!src || !dst) continue

                        var x1 = src.x, y1 = src.y
                        var x2 = dst.x, y2 = dst.y
                        var cpx = (x1 + x2) / 2
                        var cpy = (y1 + y2) / 2 - 40

                        // Glow shadow pass
                        ctx.beginPath()
                        ctx.moveTo(x1, y1)
                        ctx.quadraticCurveTo(cpx, cpy, x2, y2)
                        ctx.strokeStyle = "rgba(0,212,255,0.12)"
                        ctx.lineWidth = 8
                        ctx.stroke()

                        // Main line
                        var grad = ctx.createLinearGradient(x1, y1, x2, y2)
                        grad.addColorStop(0, "rgba(0,212,255,0.7)")
                        grad.addColorStop(1, "rgba(123,47,255,0.7)")
                        ctx.beginPath()
                        ctx.moveTo(x1, y1)
                        ctx.quadraticCurveTo(cpx, cpy, x2, y2)
                        ctx.strokeStyle = grad
                        ctx.lineWidth = 2
                        ctx.stroke()

                        // Animated dot along path (simple midpoint dot)
                        ctx.beginPath()
                        ctx.arc(cpx, cpy, 3, 0, 2 * Math.PI)
                        ctx.fillStyle = "rgba(0,212,255,0.8)"
                        ctx.fill()
                    }
                }
            }

            // ── Node repeater ──────────────────────────────────────────────
            Repeater {
                id: nodeRepeater
                model: mindMapManager.nodes

                delegate: Item {
                    id: nodeItem
                    property var nodeData: modelData
                    property string nodeId: modelData.id
                    property real nodeX: modelData.x
                    property real nodeY: modelData.y
                    property string nodeLabel: modelData.label
                    property string nodeColor: modelData.color || theme.primary
                    property bool isRoot: modelData.isRoot || false
                    property int nodeLevel: modelData.level || 0

                    property bool isEditing: false

                    width: isRoot ? 160 : 140
                    height: isRoot ? 52 : 44

                    x: nodeX - width / 2
                    y: nodeY - height / 2

                    z: 5

                    // ── Node body ──────────────────────────────────────────
                    Rectangle {
                        id: nodeBody
                        anchors.fill: parent
                        radius: isRoot ? 28 : 22
                        color: Qt.rgba(0.04, 0.04, 0.14, 0.95)
                        border.color: nodeItem.nodeColor
                        border.width: isRoot ? 2.5 : 1.8

                        // Outer glow
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -4
                            radius: parent.radius + 4
                            color: "transparent"
                            border.color: Qt.lighter(nodeItem.nodeColor, 1.2)
                            border.width: nodeMouseArea.containsMouse ? 2 : 0
                            opacity: 0.5
                            Behavior on border.width { NumberAnimation { duration: 150 } }
                        }

                        // Label or text input
                        Loader {
                            id: labelLoader
                            anchors { fill: parent; leftMargin: 10; rightMargin: isRoot ? 10 : 26; topMargin: 4; bottomMargin: 4 }
                            sourceComponent: nodeItem.isEditing ? editComponent : labelComponent
                        }

                        Component {
                            id: labelComponent
                            Text {
                                text: nodeItem.nodeLabel
                                color: nodeItem.isRoot ? nodeItem.nodeColor : theme.textPrimary
                                font.pixelSize: nodeItem.isRoot ? 14 : 12
                                font.bold: nodeItem.isRoot
                                font.letterSpacing: nodeItem.isRoot ? 2 : 0.5
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                elide: Text.ElideRight
                            }
                        }

                        Component {
                            id: editComponent
                            TextInput {
                                id: editInput
                                text: nodeItem.nodeLabel
                                color: theme.textPrimary
                                font.pixelSize: 12
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                selectByMouse: true
                                clip: true
                                Component.onCompleted: { selectAll(); forceActiveFocus() }
                                Keys.onReturnPressed: {
                                    mindMapManager.updateNodeLabel(nodeItem.nodeId, text)
                                    nodeItem.isEditing = false
                                }
                                Keys.onEscapePressed: { nodeItem.isEditing = false }
                                onActiveFocusChanged: {
                                    if (!activeFocus) {
                                        mindMapManager.updateNodeLabel(nodeItem.nodeId, text)
                                        nodeItem.isEditing = false
                                    }
                                }
                            }
                        }

                        // ── Add-child arrow button (right side) ───────────
                        Rectangle {
                            id: addChildBtn
                            visible: !nodeItem.isRoot && nodeMouseArea.containsMouse
                            anchors { right: parent.right; rightMargin: 4; verticalCenter: parent.verticalCenter }
                            width: 20; height: 20; radius: 10
                            color: addBtnHover.containsMouse ? nodeItem.nodeColor : Qt.rgba(0.04, 0.04, 0.14, 0.95)
                            border.color: nodeItem.nodeColor; border.width: 1.5
                            Behavior on color { ColorAnimation { duration: 120 } }

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 14; font.bold: true
                                color: addBtnHover.containsMouse ? "white" : nodeItem.nodeColor
                            }

                            HoverHandler { id: addBtnHover }
                            TapHandler {
                                onTapped: {
                                    var newId = mindMapManager.addChildNode(nodeItem.nodeId)
                                    edgeCanvas.repaint()
                                }
                            }
                        }

                        // Root node: add child on right
                        Rectangle {
                            id: rootAddBtn
                            visible: nodeItem.isRoot && rootAddHover.containsMouse || (nodeItem.isRoot && nodeMouseArea.containsMouse)
                            anchors { right: parent.right; rightMargin: -14; verticalCenter: parent.verticalCenter }
                            width: 28; height: 28; radius: 14
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: theme.primary }
                                GradientStop { position: 1.0; color: theme.primaryAlt }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 16; font.bold: true
                                color: "white"
                            }

                            HoverHandler { id: rootAddHover }
                            TapHandler {
                                onTapped: {
                                    mindMapManager.addChildNode(nodeItem.nodeId)
                                    edgeCanvas.repaint()
                                }
                            }
                        }
                    }

                    // Context menu
                    Rectangle {
                        id: contextMenu
                        visible: false
                        width: 160; height: 100; radius: 10
                        color: "#090924"; border.color: Qt.rgba(0.2, 0.4, 0.9, 0.5); border.width: 1
                        z: 999
                        anchors { left: nodeBody.right; leftMargin: 8; verticalCenter: nodeBody.verticalCenter }

                        ColumnLayout {
                            anchors.fill: parent; anchors.margins: 8; spacing: 4

                            Repeater {
                                model: [
                                    { label: "✎  RENAME", action: "rename" },
                                    { label: "+ ADD CHILD", action: "add" },
                                    { label: "✕  DELETE", action: "delete" }
                                ]
                                delegate: Rectangle {
                                    Layout.fillWidth: true
                                    height: 28; radius: 6
                                    color: mItemHover.containsMouse ? Qt.rgba(0, 0.83, 1.0, 0.15) : "transparent"
                                    HoverHandler { id: mItemHover }

                                    Text {
                                        anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                                        text: modelData.label
                                        font.pixelSize: 11; font.letterSpacing: 1
                                        color: modelData.action === "delete" ? theme.accent : theme.textPrimary
                                    }

                                    TapHandler {
                                        onTapped: {
                                            contextMenu.visible = false
                                            if (modelData.action === "rename") {
                                                nodeItem.isEditing = true
                                            } else if (modelData.action === "add") {
                                                mindMapManager.addChildNode(nodeItem.nodeId)
                                                edgeCanvas.repaint()
                                            } else if (modelData.action === "delete") {
                                                mindMapManager.deleteNode(nodeItem.nodeId)
                                                edgeCanvas.repaint()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // ── Drag & hover ───────────────────────────────────────
                    MouseArea {
                        id: nodeMouseArea
                        anchors.fill: nodeBody
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        drag.target: nodeItem
                        drag.smoothed: true

                        onPressed: (mouse) => {
                            if (mouse.button === Qt.RightButton) {
                                contextMenu.visible = !contextMenu.visible
                                mouse.accepted = true
                            } else {
                                isDraggingNode = true
                                contextMenu.visible = false
                            }
                        }

                        onReleased: {
                            isDraggingNode = false
                            var nx = nodeItem.x + nodeItem.width / 2
                            var ny = nodeItem.y + nodeItem.height / 2
                            mindMapManager.updateNodePosition(nodeItem.nodeId, nx, ny)
                            edgeCanvas.repaint()
                        }

                        onDoubleClicked: {
                            nodeItem.isEditing = true
                            contextMenu.visible = false
                        }
                    }

                    // Sync position from model when nodes change
                    Connections {
                        target: mindMapManager
                        function onNodesChanged() {
                            edgeCanvas.repaint()
                        }
                        function onEdgesChanged() {
                            edgeCanvas.repaint()
                        }
                    }
                }
            }
        }
    }

    property bool isDraggingNode: false

    // ── Help bar at bottom ─────────────────────────────────────────────────
    Rectangle {
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        height: 32
        color: Qt.rgba(0.02, 0.02, 0.1, 0.85)
        border.color: Qt.rgba(0.2, 0.4, 0.9, 0.2); border.width: 1
        z: 10

        Text {
            anchors.centerIn: parent
            text: "SCROLL: Pan  |  WHEEL: Zoom  |  DRAG: Move Node  |  RIGHT CLICK: Context Menu  |  DOUBLE CLICK: Rename"
            font.pixelSize: 10; font.letterSpacing: 1
            color: theme.textMuted
        }
    }

    // Initial repaint
    Component.onCompleted: edgeCanvas.repaint()
}
