import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    color: "#0a0a0a"
    
    property string currentMode: "Epic"
    property string selectedParentId: ""
    property string timeView: "Week"  // Day, Week, Month, Quarter
    property var tasksData: []
    property var precedenceData: {}
    property date startDate: new Date()
    property date endDate: new Date()
    property int totalDays: 0
    property int pixelsPerDay: 30
    
    Component.onCompleted: {
        loadTasks()
        calculateDateRange()
    }
    
    function loadTasks() {
        var allTasks = JSON.parse(taskManager.getAllTasks())
        tasksData = allTasks
        loadPrecedenceData()
        refreshTaskList()
    }
    
    function loadPrecedenceData() {
        precedenceData = {}
        console.log("Loading precedence data...")
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            var pred = precedenceManager.getPredecessor(task.type, task.id)
            if (pred && pred !== "") {
                precedenceData[task.id] = pred
                console.log("  Precedence:", task.name, "->", pred)
            }
        }
        console.log("Total precedence relationships:", Object.keys(precedenceData).length)
    }
    
    function calculateDateRange() {
        var today = new Date()
        var earliestDate = today
        var latestDate = today
        
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            if (task.start_date) {
                var taskStart = new Date(task.start_date)
                if (taskStart < earliestDate) earliestDate = taskStart
            }
            if (task.end_date) {
                var taskEnd = new Date(task.end_date)
                if (taskEnd > latestDate) latestDate = taskEnd
            }
        }
        
        startDate = earliestDate
        endDate = latestDate
        
        // Calculate total days
        totalDays = Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24)) + 1
    }
    
    function getDaysSinceStart(dateStr) {
        if (!dateStr) return 0
        var date = new Date(dateStr)
        var days = Math.ceil((date - startDate) / (1000 * 60 * 60 * 24))
        return days
    }
    
    function getDuration(startDateStr, endDateStr) {
        if (!startDateStr || !endDateStr) return 0
        var start = new Date(startDateStr)
        var end = new Date(endDateStr)
        return Math.ceil((end - start) / (1000 * 60 * 60 * 24)) + 1
    }
    
    function refreshTaskList() {
        chartTaskModel.clear()
        
        // First, collect filtered tasks
        var filteredTasks = []
        var serialNum = 0
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            
            // Filter by type
            if (task.type !== currentMode) continue
            
            // For non-Epic modes, filter by parent if selected
            if (currentMode !== "Epic" && selectedParentId !== "") {
                if (task.parent_id !== selectedParentId) continue
            }
            
            // Only show tasks with dates
            if (!task.start_date || !task.end_date) continue
            
            serialNum++
            
            filteredTasks.push({
                id: task.id,
                name: task.name,
                type: task.type,
                status: task.status,
                startDate: task.start_date || "",
                endDate: task.end_date || "",
                estimatedDays: task.estimated_days || 0,
                progress: task.progress || 0,
                predecessor: precedenceData[task.id] || "",
                row: -1,
                column: -1,
                processed: false,
                serialNum: serialNum
            })
        }
        
        console.log("Filtered tasks with serial numbers (original order):")
        for (var jj = 0; jj < filteredTasks.length; jj++) {
            console.log("  " + filteredTasks[jj].serialNum + ":", filteredTasks[jj].name, "ID:", filteredTasks[jj].id, "Pred ID:", filteredTasks[jj].predecessor)
        }
        
        // Create a map by task ID for quick lookup
        var taskMapById = {}
        for (var k = 0; k < filteredTasks.length; k++) {
            taskMapById[filteredTasks[k].id] = filteredTasks[k]
        }
        
        console.log("Processing precedence chains...")
        
        // Sort based on precedence relationships using IDs
        var currentRow = 0
        var processed = 0
        
        while (processed < filteredTasks.length) {
            var foundUnprocessed = false
            
            for (var m = 0; m < filteredTasks.length; m++) {
                var taskObj = filteredTasks[m]
                if (taskObj.processed) continue
                
                if (!taskObj.predecessor || taskObj.predecessor === "") {
                    // No predecessor - start new row
                    taskObj.row = currentRow
                    taskObj.column = 0
                    taskObj.processed = true
                    processed++
                    currentRow++
                    foundUnprocessed = true
                    console.log("    Task", taskObj.name, "has no predecessor, starting row", taskObj.row)
                } else {
                    // Has predecessor - look up by ID
                    var predTask = taskMapById[taskObj.predecessor]
                    
                    console.log("    Task", taskObj.name, "has predecessor ID", taskObj.predecessor, "-> found:", predTask ? predTask.name : "NOT FOUND")
                    
                    if (predTask && predTask.processed) {
                        // Place next to predecessor
                        taskObj.row = predTask.row
                        taskObj.column = predTask.column + 1
                        taskObj.processed = true
                        processed++
                        foundUnprocessed = true
                        console.log("      Placed at row", taskObj.row, "col", taskObj.column)
                    }
                }
            }
            
            // If no task was processed and we still have unprocessed tasks,
            // process remaining as new rows
            if (!foundUnprocessed && processed < filteredTasks.length) {
                for (var n = 0; n < filteredTasks.length; n++) {
                    var remainingTask = filteredTasks[n]
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
        
        // Sort by row, then by column
        filteredTasks.sort(function(a, b) {
            if (a.row !== b.row) return a.row - b.row
            return a.column - b.column
        })
        
        console.log("Sorted tasks by precedence:")
        for (var p = 0; p < filteredTasks.length; p++) {
            console.log("  Task:", filteredTasks[p].name, "Row:", filteredTasks[p].row, "Col:", filteredTasks[p].column)
        }
        
        // Populate the model with sorted tasks, including display row info
        var displayRow = -1
        for (var q = 0; q < filteredTasks.length; q++) {
            var sortedTask = filteredTasks[q]
            
            // Assign display row (increment only when chain row changes)
            if (q === 0 || sortedTask.row !== filteredTasks[q-1].row) {
                displayRow++
            }
            
            console.log("  Appending:", sortedTask.name, "chainRow:", sortedTask.row, "displayRow:", displayRow)
            
            chartTaskModel.append({
                taskId: sortedTask.id,
                taskName: sortedTask.name,
                taskType: sortedTask.type,
                taskStatus: sortedTask.status,
                startDate: sortedTask.startDate,
                endDate: sortedTask.endDate,
                estimatedDays: sortedTask.estimatedDays,
                progress: sortedTask.progress,
                chainRow: sortedTask.row,
                chainColumn: sortedTask.column,
                displayRow: displayRow
            })
        }
    }
    
    function refreshParentList() {
        parentListModel.clear()
        
        if (currentMode === "Epic") {
            return
        }
        
        var parentType = ""
        if (currentMode === "Feature") parentType = "Epic"
        else if (currentMode === "PBI") parentType = "Feature"
        else if (currentMode === "Task") parentType = "PBI"
        
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            if (task.type === parentType) {
                parentListModel.append({
                    id: task.id,
                    name: task.name
                })
            }
        }
        
        if (parentListModel.count > 0) {
            parentSelectorCombo.currentIndex = 0
        }
    }
    
    function getColorForTaskType(taskType) {
        if (taskType === "Epic") return "#8b5cf6"
        if (taskType === "Feature") return "#3b82f6"
        if (taskType === "PBI") return "#10b981"
        if (taskType === "Task") return "#f59e0b"
        return "#6b7280"
    }
    
    function getTimelineWidth() {
        // Calculate timeline width based on time view
        if (timeView === "Day") return chartTaskModel.count * 1200
        if (timeView === "Week") return chartTaskModel.count * 800
        if (timeView === "Month") return chartTaskModel.count * 400
        if (timeView === "Quarter") return chartTaskModel.count * 200
        return 2000
    }
    
    // Task model
    ListModel {
        id: chartTaskModel
    }
    
    // Parent list model
    ListModel {
        id: parentListModel
    }
    
    // Gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#0f0e17" }
            GradientStop { position: 0.5; color: "#16213e" }
            GradientStop { position: 1.0; color: "#1a0a2e" }
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 20
        
        // Header with controls
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
                text: "Gantt Chart - Timeline View"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
            
            // Time View Selector
            ComboBox {
                id: timeViewCombo
                Layout.preferredWidth: 120
                Layout.preferredHeight: 36
                model: ["Day", "Week", "Month", "Quarter"]
                currentIndex: 1  // Default to Week
                
                contentItem: Text {
                    text: timeViewCombo.displayText
                    font.pixelSize: 12
                    font.bold: true
                    color: "white"
                    verticalAlignment: Text.AlignVCenter
                    leftPadding: 12
                }
                
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#10b981" }
                        GradientStop { position: 1.0; color: "#059669" }
                    }
                }
                
                delegate: ItemDelegate {
                    width: timeViewCombo.width
                    
                    contentItem: Text {
                        text: modelData
                        font.pixelSize: 12
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.highlighted ? "#4b5563" : "#1f2937"
                    }
                }
                
                popup: Popup {
                    y: timeViewCombo.height
                    width: timeViewCombo.width
                    padding: 0
                    
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: timeViewCombo.popup.visible ? timeViewCombo.delegateModel : null
                        currentIndex: timeViewCombo.highlightedIndex
                    }
                    
                    background: Rectangle {
                        color: "#1f2937"
                        radius: 10
                        border.color: "#374151"
                        border.width: 1
                    }
                }
                
                onCurrentTextChanged: {
                    timeView = currentText
                }
            }
            
            // Task Type Filter
            ComboBox {
                id: taskModeCombo
                Layout.preferredWidth: 120
                Layout.preferredHeight: 36
                model: ["Epic", "Feature", "PBI", "Task"]
                currentIndex: 0
                
                contentItem: Text {
                    text: taskModeCombo.displayText
                    font.pixelSize: 12
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
                        font.pixelSize: 12
                        color: "white"
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    background: Rectangle {
                        color: parent.highlighted ? "#4b5563" : "#1f2937"
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
                    selectedParentId = ""
                    refreshParentList()
                    refreshTaskList()
                }
            }
            
            // Parent Selector
            ComboBox {
                id: parentSelectorCombo
                Layout.preferredWidth: 180
                Layout.preferredHeight: 36
                visible: currentMode !== "Epic"
                enabled: parentListModel.count > 0
                
                model: parentListModel
                textRole: "name"
                
                displayText: currentIndex >= 0 ? model.get(currentIndex).name : "Select Parent"
                
                contentItem: Text {
                    text: parentSelectorCombo.displayText
                    font.pixelSize: 11
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
                        font.pixelSize: 11
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
        
        // Timeline Chart Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(0.08, 0.08, 0.12, 0.95)
            radius: 20
            border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
            border.width: 1
            
            ScrollView {
                anchors.fill: parent
                anchors.margins: 20
                clip: true
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                
                Item {
                    width: Math.max(250 + totalDays * pixelsPerDay, 1200)
                    height: Math.max(timelineContent.height + (timeView === "Day" ? 50 : 45), parent.parent.height - 40)
                    
                    // Date markers (X-axis)
                    Column {
                        x: 250
                        y: 0
                        spacing: 0
                        
                        // Day abbreviation row (only for Day view)
                        Row {
                            spacing: 0
                            visible: timeView === "Day"
                            
                            Repeater {
                                model: totalDays
                                
                                Rectangle {
                                    width: pixelsPerDay
                                    height: 20
                                    color: Qt.rgba(0.15, 0.15, 0.2, 0.9)
                                    border.color: "#374151"
                                    border.width: 1
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            var date = new Date(startDate.getTime() + index * 86400000)
                                            var dayNames = ["S", "M", "T", "W", "T", "F", "S"]
                                            return dayNames[date.getDay()]
                                        }
                                        font.pixelSize: 10
                                        font.bold: true
                                        color: {
                                            var date = new Date(startDate.getTime() + index * 86400000)
                                            var day = date.getDay()
                                            return (day === 0 || day === 6) ? "#f87171" : "#94a3b8"
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Date/time markers row
                        Row {
                            spacing: 0
                            
                            Repeater {
                                model: totalDays
                                
                                Rectangle {
                                    width: pixelsPerDay
                                    height: timeView === "Day" ? 25 : 40
                                    color: {
                                        var date = new Date(startDate.getTime() + index * 86400000)
                                        var day = date.getDay()
                                        return (day === 0 || day === 6) ? Qt.rgba(0.25, 0.15, 0.15, 0.8) : Qt.rgba(0.12, 0.12, 0.16, 0.8)
                                    }
                                    border.color: "#374151"
                                    border.width: 1
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: {
                                            var date = new Date(startDate.getTime() + index * 86400000)
                                            if (timeView === "Day") {
                                                return date.getDate()
                                            } else if (timeView === "Week") {
                                                if (date.getDay() === 1 || index === 0) { // Monday or first day
                                                    return date.toLocaleDateString('en-US', {month: 'short', day: 'numeric'})
                                                }
                                                return ""
                                            } else if (timeView === "Month") {
                                                if (date.getDate() === 1 || index === 0) {
                                                    return date.toLocaleDateString('en-US', {month: 'short', year: 'numeric'})
                                                }
                                                return ""
                                            } else { // Quarter
                                                var month = date.getMonth()
                                                if ((month % 3 === 0 && date.getDate() === 1) || index === 0) {
                                                    return "Q" + Math.floor(month / 3 + 1) + " " + date.getFullYear()
                                                }
                                                return ""
                                            }
                                        }
                                        font.pixelSize: timeView === "Day" ? 11 : 9
                                        font.bold: timeView === "Day"
                                        color: {
                                            var date = new Date(startDate.getTime() + index * 86400000)
                                            var day = date.getDay()
                                            return (day === 0 || day === 6) ? "#f87171" : "white"
                                        }
                                        rotation: timeView === "Week" ? -45 : 0
                                    }
                                }
                            }
                        }
                    }
                    
                    Column {
                        id: timelineContent
                        y: timeView === "Day" ? 45 : 40
                        spacing: 0
                        
                        // Timeline rows
                        Repeater {
                            model: chartTaskModel.count > 0 ? getUniqueDisplayRows() : []
                            
                            function getUniqueDisplayRows() {
                                var rows = []
                                for (var i = 0; i < chartTaskModel.count; i++) {
                                    var row = chartTaskModel.get(i).displayRow
                                    if (rows.indexOf(row) === -1) {
                                        rows.push(row)
                                    }
                                }
                                rows.sort(function(a, b) { return a - b })
                                return rows
                            }
                            
                            Rectangle {
                                width: 250 + totalDays * pixelsPerDay
                                height: 60
                                color: index % 2 === 0 ? Qt.rgba(0.12, 0.12, 0.16, 0.8) : Qt.rgba(0.15, 0.15, 0.2, 0.8)
                                
                                property int currentDisplayRow: modelData
                                
                                // Timeline bars area
                                Rectangle {
                                    width: parent.width
                                    height: parent.height
                                    color: "transparent"
                                    border.color: "#374151"
                                    border.width: 1
                                    
                                    // Render all tasks in this display row
                                    Repeater {
                                        model: chartTaskModel
                                        
                                        // Task bar (only if it belongs to current display row)
                                        Rectangle {
                                            visible: model.displayRow === currentDisplayRow
                                            x: visible ? 250 + getDaysSinceStart(model.startDate) * pixelsPerDay : 0
                                            y: 10
                                            width: visible ? getDuration(model.startDate, model.endDate) * pixelsPerDay : 0
                                            height: 40
                                            radius: 6
                                            color: getColorForTaskType(model.taskType)
                                            opacity: 0.9
                                            clip: true
                                            
                                            // Progress indicator
                                            Rectangle {
                                                anchors.left: parent.left
                                                anchors.top: parent.top
                                                anchors.bottom: parent.bottom
                                                width: parent.width * (model.progress / 100)
                                                radius: parent.radius
                                                color: Qt.lighter(getColorForTaskType(model.taskType), 1.3)
                                                opacity: 0.5
                                            }
                                            
                                            // Task name inside bar
                                            Text {
                                                anchors.fill: parent
                                                anchors.margins: 8
                                                text: model.taskName + " (" + model.progress + "%)"
                                                font.pixelSize: 11
                                                font.bold: true
                                                color: "white"
                                                elide: Text.ElideRight
                                                verticalAlignment: Text.AlignVCenter
                                                clip: true
                                            }
                                            
                                            // Click interaction
                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                
                                                onEntered: parent.opacity = 1.0
                                                onExited: parent.opacity = 0.9
                                                
                                                onClicked: {
                                                    statusDialog.taskId = model.taskId
                                                    statusDialog.taskName = model.taskName
                                                    statusDialog.currentProgress = model.progress
                                                    statusDialog.open()
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
            
            // Empty state
            Text {
                anchors.centerIn: parent
                text: chartTaskModel.count === 0 ? "No tasks with dates found\n\nAdd start and end dates to tasks to see them in the timeline" : ""
                font.pixelSize: 16
                color: "#6b7280"
                horizontalAlignment: Text.AlignHCenter
                visible: chartTaskModel.count === 0
            }
        }
    }
    
    // Status Update Dialog
    Dialog {
        id: statusDialog
        anchors.centerIn: parent
        width: 400
        height: 280
        modal: true
        
        property string taskId: ""
        property string taskName: ""
        property int currentProgress: 0
        
        background: Rectangle {
            radius: 15
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#1f2937" }
                GradientStop { position: 1.0; color: "#111827" }
            }
            border.color: "#374151"
            border.width: 2
        }
        
        contentItem: Item {
            implicitWidth: 400
            implicitHeight: 280
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    Layout.fillWidth: true
                    text: "Update Task Progress"
                    font.pixelSize: 18
                    font.bold: true
                    color: "white"
                }
                
                Text {
                    Layout.fillWidth: true
                    text: statusDialog.taskName
                    font.pixelSize: 14
                    color: "#9ca3af"
                    wrapMode: Text.WordWrap
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: "#374151"
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        text: "Progress: " + progressSlider.value + "%"
                        font.pixelSize: 14
                        color: "white"
                        font.bold: true
                    }
                    
                    Slider {
                        id: progressSlider
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        stepSize: 5
                        value: statusDialog.currentProgress
                        
                        background: Rectangle {
                            x: progressSlider.leftPadding
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            width: progressSlider.availableWidth
                            height: 8
                            radius: 4
                            color: "#374151"
                            
                            Rectangle {
                                width: progressSlider.visualPosition * parent.width
                                height: parent.height
                                color: "#6366f1"
                                radius: 4
                            }
                        }
                        
                        handle: Rectangle {
                            x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                            y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                            width: 20
                            height: 20
                            radius: 10
                            color: progressSlider.pressed ? "#4f46e5" : "#6366f1"
                            border.color: "white"
                            border.width: 2
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Item { Layout.fillWidth: true }
                    
                    Button {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        text: "Cancel"
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            radius: 8
                            color: parent.pressed ? "#4b5563" : (parent.hovered ? "#6b7280" : "#374151")
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        onClicked: statusDialog.close()
                    }
                    
                    Button {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 40
                        text: "Update"
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            radius: 8
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: parent.pressed ? "#4f46e5" : (parent.hovered ? "#6366f1" : "#8b5cf6") }
                                GradientStop { position: 1.0; color: parent.pressed ? "#4338ca" : (parent.hovered ? "#4f46e5" : "#6366f1") }
                            }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        onClicked: {
                            taskManager.updateTaskProgress(statusDialog.taskId, Math.round(progressSlider.value))
                            statusDialog.close()
                        }
                    }
                }
            }
        }
    }
    
    // Connections to TaskManager
    Connections {
        target: taskManager
        
        function onTaskCreated() {
            loadTasks()
            calculateDateRange()
        }
        
        function onTaskUpdated() {
            loadTasks()
            calculateDateRange()
        }
    }
}
