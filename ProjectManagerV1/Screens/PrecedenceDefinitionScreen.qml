import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    color: "#0a0a0a"
    
    property string currentMode: "Epic"
    property var tasksData: []
    property string selectedParentId: ""  // Track selected parent
    
    Component.onCompleted: {
        loadTasks()
    }
    
    function loadTasks() {
        var allTasksJson = taskManager.getAllTasks()
        tasksData = JSON.parse(allTasksJson)
        taskListModel.clear()
        refreshTaskList()
    }
    
    function refreshTaskList() {
        taskListModel.clear()
        
        // Load precedence data for current project
        var projectFolder = projectManager.getCurrentProjectFolder()
        if (projectFolder) {
            precedenceManager.loadProjectPrecedence(projectFolder)
        }
        
        // Show all tasks of the current mode type
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            
            // Filter by type
            if (task.type !== currentMode) continue
            
            // For non-Epic modes, filter by parent if selected
            if (currentMode !== "Epic" && selectedParentId !== "") {
                if (task.parent_id !== selectedParentId) continue
            }
            
            // Get predecessor ID from PrecedenceManager
            var predecessorId = precedenceManager.getPredecessor(task.type, task.id)
            
            taskListModel.append({
                taskId: task.id,
                taskName: task.name,
                taskType: task.type,
                taskStatus: task.status,
                estimatedDays: task.estimated_days || 0,
                startDate: task.start_date || "",
                endDate: task.end_date || "",
                predecessor: "",
                predecessorId: predecessorId || ""
            })
        }
        
        // Convert predecessor IDs to row numbers for display
        for (var j = 0; j < taskListModel.count; j++) {
            var item = taskListModel.get(j)
            if (item.predecessorId) {
                // Find the row number of the predecessor task
                for (var k = 0; k < taskListModel.count; k++) {
                    if (taskListModel.get(k).taskId === item.predecessorId) {
                        item.predecessor = k.toString()
                        break
                    }
                }
            }
        }
        
        // Sort for link diagram view
        sortTasksForDiagram()
    }
    
    function refreshParentList() {
        parentListModel.clear()
        
        if (currentMode === "Epic") {
            return  // Epic has no parent
        }
        
        // Determine parent type
        var parentType = ""
        if (currentMode === "Feature") parentType = "Epic"
        else if (currentMode === "PBI") parentType = "Feature"
        else if (currentMode === "Task") parentType = "PBI"
        
        // Populate parent list
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            if (task.type === parentType) {
                parentListModel.append({
                    id: task.id,
                    name: task.name
                })
            }
        }
        
        // Reset selection
        if (parentListModel.count > 0) {
            parentSelectorCombo.currentIndex = 0
        }
    }
    
    function sortTasksForDiagram() {
        sortedDiagramModel.clear()
        
        // Create array of tasks with their serial numbers
        var tasks = []
        for (var i = 0; i < taskListModel.count; i++) {
            var task = taskListModel.get(i)
            tasks.push({
                serialNum: i + 1,
                taskId: task.taskId,
                taskName: task.taskName,
                taskType: task.taskType,
                taskStatus: task.taskStatus,
                estimatedDays: task.estimatedDays,
                startDate: task.startDate,
                endDate: task.endDate,
                predecessor: task.predecessor || "",
                row: -1,
                column: -1,
                processed: false
            })
        }
        
        // Create a map by serial number for quick lookup
        var taskMap = {}
        for (var j = 0; j < tasks.length; j++) {
            taskMap[tasks[j].serialNum] = tasks[j]
        }
        
        // Calculate positions
        var currentRow = 0
        var processed = 0
        
        // Process all tasks
        while (processed < tasks.length) {
            var foundUnprocessed = false
            
            for (var k = 0; k < tasks.length; k++) {
                var taskObj = tasks[k]
                if (taskObj.processed) continue
                
                if (!taskObj.predecessor || taskObj.predecessor === "") {
                    // No predecessor - start new row
                    taskObj.row = currentRow
                    taskObj.column = 0
                    taskObj.processed = true
                    processed++
                    currentRow++
                    foundUnprocessed = true
                } else {
                    // Has predecessor - check if predecessor is processed
                    var predNum = parseInt(taskObj.predecessor)
                    var predTask = taskMap[predNum]
                    
                    if (predTask && predTask.processed) {
                        // Place next to predecessor
                        taskObj.row = predTask.row
                        taskObj.column = predTask.column + 1
                        taskObj.processed = true
                        processed++
                        foundUnprocessed = true
                    }
                }
            }
            
            // If no task was processed and we still have unprocessed tasks,
            // process remaining as new rows
            if (!foundUnprocessed && processed < tasks.length) {
                for (var m = 0; m < tasks.length; m++) {
                    var remainingTask = tasks[m]
                    if (!remainingTask.processed) {
                        remainingTask.row = currentRow
                        remainingTask.column = 0
                        remainingTask.processed = true
                        processed++
                        currentRow++
                        break
                    }
                }
            }
        }
        
        // Build sorted model
        for (var n = 0; n < tasks.length; n++) {
            var sortedTask = tasks[n]
            var hasPredecessor = sortedTask.predecessor !== ""
            
            sortedDiagramModel.append({
                displayIndex: sortedTask.serialNum,
                taskId: sortedTask.taskId,
                taskName: sortedTask.taskName,
                taskType: sortedTask.taskType,
                taskStatus: sortedTask.taskStatus,
                estimatedDays: sortedTask.estimatedDays,
                startDate: sortedTask.startDate,
                endDate: sortedTask.endDate,
                predecessor: sortedTask.predecessor,
                hasPredecessor: hasPredecessor,
                chainRow: sortedTask.row,
                chainColumn: sortedTask.column
            })
        }
    }
    
    function getColorForTaskType(taskType) {
        if (taskType === "Epic") return "#8b5cf6"      // Purple
        if (taskType === "Feature") return "#3b82f6"   // Blue
        if (taskType === "PBI") return "#10b981"       // Green
        if (taskType === "Task") return "#f59e0b"      // Amber
        return "#6b7280"                                 // Gray
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            Button {
                Layout.preferredWidth: 100
                Layout.preferredHeight: 40
                text: "← Back"
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    radius: 10
                    color: parent.pressed ? "#4b5563" : (parent.hovered ? "#6b7280" : "#374151")
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                
                onClicked: {
                    screenLoader.loadScreen("Screens/GanttChartScreen.qml")
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { mouse.accepted = false }
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: "Precedence Definition"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
        }
        
        // Main content area - Split into two sections
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 20
            
            // Left side - Tasks View
            Rectangle {
                Layout.preferredWidth: 400
                Layout.fillHeight: true
                color: Qt.rgba(0.08, 0.08, 0.12, 0.95)
                radius: 20
                border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Text {
                            Layout.fillWidth: true
                            text: "Tasks"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                        }
                        
                        // Task Type Filter
                        ComboBox {
                            id: taskModeCombo
                            Layout.preferredWidth: 130
                            Layout.preferredHeight: 36
                            model: ["Epic", "Feature", "PBI", "Task"]
                            currentIndex: 0
                            
                            contentItem: Text {
                                text: taskModeCombo.displayText
                                font.pixelSize: 13
                                font.bold: true
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                            }
                            
                            background: Rectangle {
                                radius: 10
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: "#6366f1" }
                                    GradientStop { position: 1.0; color: "#8b5cf6" }
                                }
                            }
                            
                            delegate: ItemDelegate {
                                width: taskModeCombo.width
                                
                                contentItem: Text {
                                    text: modelData
                                    color: "white"
                                    font.pixelSize: 13
                                    verticalAlignment: Text.AlignVCenter
                                    leftPadding: 12
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? "#4b5563" : "#374151"
                                }
                            }
                            
                            popup: Popup {
                                y: taskModeCombo.height
                                width: taskModeCombo.width
                                padding: 0
                                
                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: contentHeight
                                    model: taskModeCombo.popup.visible ? taskModeCombo.delegateModel : null
                                    currentIndex: taskModeCombo.highlightedIndex
                                }
                                
                                background: Rectangle {
                                    color: "#1f2937"
                                    radius: 10
                                    border.color: "#374151"
                                    border.width: 1
                                }
                            }
                            
                            onCurrentTextChanged: {
                                currentMode = currentText
                                selectedParentId = ""  // Reset parent selection
                                refreshParentList()
                                refreshTaskList()
                            }
                        }
                        
                        // Parent Selector (visible for non-Epic modes)
                        ComboBox {
                            id: parentSelectorCombo
                            Layout.preferredWidth: 200
                            Layout.preferredHeight: 36
                            visible: currentMode !== "Epic"
                            enabled: parentListModel.count > 0
                            
                            model: ListModel { id: parentListModel }
                            textRole: "name"
                            
                            displayText: currentIndex >= 0 ? model.get(currentIndex).name : "Select Parent"
                            
                            contentItem: Text {
                                text: parentSelectorCombo.displayText
                                font.pixelSize: 12
                                color: "white"
                                verticalAlignment: Text.AlignVCenter
                                leftPadding: 12
                                elide: Text.ElideRight
                            }
                            
                            background: Rectangle {
                                radius: 10
                                color: parent.enabled ? "#374151" : "#1f2937"
                                border.color: "#4b5563"
                                border.width: 1
                            }
                            
                            delegate: ItemDelegate {
                                width: parentSelectorCombo.width
                                
                                contentItem: Text {
                                    text: model.name
                                    font.pixelSize: 12
                                    color: "white"
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.highlighted ? "#4b5563" : "#1f2937"
                                }
                            }
                            
                            popup: Popup {
                                y: parentSelectorCombo.height
                                width: parentSelectorCombo.width
                                padding: 0
                                
                                contentItem: ListView {
                                    clip: true
                                    implicitHeight: Math.min(contentHeight, 200)
                                    model: parentSelectorCombo.popup.visible ? parentSelectorCombo.delegateModel : null
                                    currentIndex: parentSelectorCombo.highlightedIndex
                                    ScrollBar.vertical: ScrollBar {}
                                }
                                
                                background: Rectangle {
                                    color: "#1f2937"
                                    radius: 10
                                    border.color: "#374151"
                                    border.width: 1
                                }
                            }
                            
                            onCurrentIndexChanged: {
                                if (currentIndex >= 0 && model.count > 0) {
                                    selectedParentId = model.get(currentIndex).id
                                    refreshTaskList()
                                }
                            }
                        }
                    }
                    
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        
                        ListView {
                            id: taskListView
                            model: taskListModel
                            spacing: 8
                            
                            delegate: Rectangle {
                                width: taskListView.width
                                height: 60
                                color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                                radius: 10
                                border.color: taskMouseArea.containsMouse ? getColorForTaskType(model.taskType) : "transparent"
                                border.width: 2
                                
                                // Left color indicator strip
                                Rectangle {
                                    width: 4
                                    height: parent.height
                                    anchors.left: parent.left
                                    radius: 10
                                    color: getColorForTaskType(model.taskType)
                                }
                                
                                Behavior on border.color { ColorAnimation { duration: 200 } }
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 12
                                    spacing: 10
                                    
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 4
                                        
                                        Text {
                                            text: model.taskName
                                            font.pixelSize: 14
                                            font.bold: true
                                            color: "white"
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        
                                        Text {
                                            text: model.taskType + " • " + model.taskStatus
                                            font.pixelSize: 11
                                            color: "#94a3b8"
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    id: taskMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        console.log("Selected task:", model.taskName)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            // Right side - Tabbed view for Sheet and Link Diagram
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Qt.rgba(0.08, 0.08, 0.12, 0.95)
                radius: 20
                border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
                border.width: 1
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 15
                    
                    // Tab buttons
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Button {
                            id: sheetTabBtn
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 150
                            text: "Sheet View"
                            
                            property bool isActive: tabView.currentIndex === 0
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                radius: 10
                                color: parent.isActive ? "#6366f1" : (parent.hovered ? "#4b5563" : "#374151")
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            
                            onClicked: tabView.currentIndex = 0
                        }
                        
                        Button {
                            id: linkDiagramTabBtn
                            Layout.preferredHeight: 40
                            Layout.preferredWidth: 180
                            text: "Link Diagram View"
                            
                            property bool isActive: tabView.currentIndex === 1
                            
                            contentItem: Text {
                                text: parent.text
                                font.pixelSize: 14
                                font.bold: true
                                color: "white"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            
                            background: Rectangle {
                                radius: 10
                                color: parent.isActive ? "#6366f1" : (parent.hovered ? "#4b5563" : "#374151")
                                Behavior on color { ColorAnimation { duration: 200 } }
                            }
                            
                            onClicked: tabView.currentIndex = 1
                        }
                        
                        Item { Layout.fillWidth: true }
                    }
                    
                    // Content area
                    StackLayout {
                        id: tabView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: 0
                        
                        // Sheet View
                        Rectangle {
                            color: "transparent"
                            
                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 0
                                
                                // Header row
                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 50
                                    color: "#1f2937"
                                    radius: 10
                                    
                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 5
                                        
                                        Text {
                                            Layout.preferredWidth: 50
                                            text: "S.No"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                        
                                        Text {
                                            Layout.fillWidth: true
                                            Layout.minimumWidth: 150
                                            text: "Item Name"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                        }
                                        
                                        Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                        
                                        Text {
                                            Layout.preferredWidth: 100
                                            text: "Est. Days"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                        
                                        Text {
                                            Layout.preferredWidth: 120
                                            text: "Start Date"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                        
                                        Text {
                                            Layout.preferredWidth: 120
                                            text: "End Date"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                        
                                        Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                        
                                        Text {
                                            Layout.preferredWidth: 100
                                            text: "Predecessor"
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: "white"
                                            horizontalAlignment: Text.AlignHCenter
                                        }
                                    }
                                }
                                
                                // Data rows
                                ScrollView {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    clip: true
                                    
                                    ListView {
                                        id: sheetListView
                                        model: taskListModel
                                        spacing: 2
                                        
                                        delegate: Rectangle {
                                            width: sheetListView.width
                                            height: 50
                                            color: index % 2 === 0 ? Qt.rgba(0.12, 0.12, 0.16, 0.8) : Qt.rgba(0.15, 0.15, 0.2, 0.8)
                                            
                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.margins: 10
                                                spacing: 5
                                                
                                                Text {
                                                    Layout.preferredWidth: 50
                                                    text: (index + 1).toString()
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                
                                                Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                                
                                                Text {
                                                    Layout.fillWidth: true
                                                    Layout.minimumWidth: 150
                                                    text: model.taskName
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    elide: Text.ElideRight
                                                }
                                                
                                                Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                                
                                                Text {
                                                    Layout.preferredWidth: 100
                                                    text: model.estimatedDays || "-"
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                
                                                Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                                
                                                Text {
                                                    Layout.preferredWidth: 120
                                                    text: model.startDate || "-"
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                
                                                Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                                
                                                Text {
                                                    Layout.preferredWidth: 120
                                                    text: model.endDate || "-"
                                                    font.pixelSize: 12
                                                    color: "white"
                                                    horizontalAlignment: Text.AlignHCenter
                                                }
                                                
                                                Rectangle { width: 1; Layout.fillHeight: true; color: "#374151" }
                                                
                                                Rectangle {
                                                    Layout.preferredWidth: 100
                                                    Layout.fillHeight: true
                                                    color: "transparent"
                                                    
                                                    TextField {
                                                        anchors.centerIn: parent
                                                        width: parent.width - 10
                                                        height: 30
                                                        text: model.predecessor || ""
                                                        placeholderText: "-"
                                                        font.pixelSize: 12
                                                        horizontalAlignment: Text.AlignHCenter
                                                        color: "white"
                                                        
                                                        background: Rectangle {
                                                            color: parent.activeFocus ? Qt.rgba(0.2, 0.2, 0.3, 0.8) : "transparent"
                                                            border.color: parent.activeFocus ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.5)
                                                            border.width: 1
                                                            radius: 5
                                                        }
                                                        
                                                        onEditingFinished: {
                                                            // Save predecessor when user finishes editing
                                                            var taskId = model.taskId
                                                            var taskType = model.taskType
                                                            var predecessorRowNum = text.trim()
                                                            
                                                            // Convert row number to task ID
                                                            var predecessorId = ""
                                                            if (predecessorRowNum !== "") {
                                                                var rowNum = parseInt(predecessorRowNum)
                                                                if (!isNaN(rowNum) && rowNum >= 0 && rowNum < taskListModel.count) {
                                                                    predecessorId = taskListModel.get(rowNum).taskId
                                                                    console.log("Converting row", rowNum, "to ID", predecessorId)
                                                                }
                                                            }
                                                            
                                                            precedenceManager.setPredecessor(taskType, taskId, predecessorId)
                                                            
                                                            // Update model to show row number and store ID
                                                            model.predecessor = predecessorRowNum
                                                            model.predecessorId = predecessorId
                                                            
                                                            // Refresh link diagram sorting
                                                            sortTasksForDiagram()
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Link Diagram View
                        Rectangle {
                            color: "transparent"
                            
                            // Sorted task list model for link diagram
                            ListModel {
                                id: sortedDiagramModel
                            }
                            
                            ScrollView {
                                anchors.fill: parent
                                clip: true
                                contentWidth: diagramContainer.childrenRect.width + 100
                                contentHeight: diagramContainer.childrenRect.height + 100
                                ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                                
                                Item {
                                    id: diagramContainer
                                    width: childrenRect.width + 100
                                    height: childrenRect.height + 100
                                    
                                    Repeater {
                                        id: diagramRepeater
                                        model: sortedDiagramModel
                                        
                                        Item {
                                            id: taskItem
                                            width: 280
                                            height: 120
                                            
                                            property int chainRow: model.chainRow || 0
                                            property int chainCol: model.chainColumn || 0
                                            
                                            x: 50 + (chainCol * 280)
                                            y: 50 + (chainRow * 180)
                                            
                                            // Task block
                                            Rectangle {
                                                id: taskBlock
                                                width: 200
                                                height: 120
                                                color: Qt.rgba(0.15, 0.15, 0.2, 0.9)
                                                radius: 12
                                                border.color: getColorForTaskType(model.taskType)
                                                border.width: 3
                                                
                                                // Left color strip
                                                Rectangle {
                                                    width: 6
                                                    height: parent.height
                                                    anchors.left: parent.left
                                                    radius: 12
                                                    color: getColorForTaskType(model.taskType)
                                                }
                                                
                                                ColumnLayout {
                                                    anchors.fill: parent
                                                        anchors.margins: 15
                                                        spacing: 8
                                                        
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: model.displayIndex + ". " + model.taskName
                                                            font.pixelSize: 13
                                                            font.bold: true
                                                            color: "white"
                                                            wrapMode: Text.WordWrap
                                                            maximumLineCount: 2
                                                            elide: Text.ElideRight
                                                        }
                                                        
                                                        Text {
                                                            text: model.taskType
                                                            font.pixelSize: 10
                                                            color: getColorForTaskType(model.taskType)
                                                        }
                                                        
                                                        RowLayout {
                                                            Layout.fillWidth: true
                                                            spacing: 5
                                                            
                                                            Text {
                                                                text: "📅 " + (model.estimatedDays || "0") + " days"
                                                                font.pixelSize: 10
                                                                color: "#94a3b8"
                                                            }
                                                        }
                                                        
                                                        Text {
                                                            Layout.fillWidth: true
                                                            text: model.predecessor ? "← Depends on: #" + model.predecessor : "No predecessor"
                                                            font.pixelSize: 9
                                                            color: model.predecessor ? "#fbbf24" : "#6b7280"
                                                            elide: Text.ElideRight
                                                        }
                                                    }
                                                }
                                                
                                                // Rope-like connector to next task (if this task has a successor)
                                                Canvas {
                                                    id: ropeCanvas
                                                    x: 200
                                                    y: 0
                                                    width: 80
                                                    height: 120
                                                    
                                                    property bool hasSuccessor: false
                                                    
                                                    // Check if any task has this task as predecessor
                                                    Component.onCompleted: {
                                                        checkForSuccessor()
                                                    }
                                                    
                                                    Connections {
                                                        target: sortedDiagramModel
                                                        function onCountChanged() {
                                                            ropeCanvas.checkForSuccessor()
                                                        }
                                                    }
                                                    
                                                    function checkForSuccessor() {
                                                        hasSuccessor = false
                                                        var mySerialNum = model.displayIndex.toString()
                                                        
                                                        for (var i = 0; i < sortedDiagramModel.count; i++) {
                                                            var otherTask = sortedDiagramModel.get(i)
                                                            if (otherTask.predecessor === mySerialNum) {
                                                                hasSuccessor = true
                                                                break
                                                            }
                                                        }
                                                        requestPaint()
                                                    }
                                                    
                                                    visible: hasSuccessor
                                                    
                                                    onPaint: {
                                                        var ctx = getContext("2d")
                                                        ctx.clearRect(0, 0, width, height)
                                                        
                                                        if (hasSuccessor) {
                                                            // Draw simple horizontal connector with slight sag
                                                            ctx.strokeStyle = "#6366f1"
                                                            ctx.lineWidth = 3
                                                            ctx.lineCap = "round"
                                                            
                                                            // Main curve - horizontal with slight downward sag
                                                            ctx.beginPath()
                                                            ctx.moveTo(0, 60) // Start from left edge (right side of current task)
                                                            
                                                            // Bezier curve with slight sag
                                                            var controlX1 = 20
                                                            var controlY1 = 65 // Slight sag
                                                            var controlX2 = 60
                                                            var controlY2 = 65 // Slight sag
                                                            var endX = 80
                                                            var endY = 60
                                                            
                                                            ctx.bezierCurveTo(controlX1, controlY1, controlX2, controlY2, endX, endY)
                                                            ctx.stroke()
                                                            
                                                            // Add chain link circles
                                                            for (var i = 0; i <= 1; i += 0.25) {
                                                                var t = i
                                                                var x = Math.pow(1-t, 3) * 0 + 
                                                                       3 * Math.pow(1-t, 2) * t * controlX1 +
                                                                       3 * (1-t) * Math.pow(t, 2) * controlX2 +
                                                                       Math.pow(t, 3) * endX
                                                                var y = Math.pow(1-t, 3) * 60 + 
                                                                       3 * Math.pow(1-t, 2) * t * controlY1 +
                                                                       3 * (1-t) * Math.pow(t, 2) * controlY2 +
                                                                       Math.pow(t, 3) * endY
                                                                
                                                                ctx.beginPath()
                                                                ctx.arc(x, y, 4, 0, 2 * Math.PI)
                                                                ctx.fillStyle = "#818cf8"
                                                                ctx.fill()
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
    
    // Task List Model
    ListModel {
        id: taskListModel
    }
    
    // Connections to TaskManager
    Connections {
        target: taskManager
        
        function onTaskCreated() {
            loadTasks()
        }
    }
    
    // Connections to PrecedenceManager for date updates
    Connections {
        target: precedenceManager
        
        function onTaskDatesUpdated(taskType, taskId, startDate, endDate) {
            // Reload tasks to reflect updated dates
            loadTasks()
        }
    }
}
