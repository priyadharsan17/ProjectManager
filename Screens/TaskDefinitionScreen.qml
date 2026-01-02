import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import "../Components"

Rectangle {
    id: root
    color: "#0a0a0a"
    
    property string currentMode: "Epic"
    property var tasksData: []
    property string selectedParentId: ""
    
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
        
        // Show all tasks of the current mode type
        for (var i = 0; i < tasksData.length; i++) {
            var task = tasksData[i]
            if (task.type === currentMode) {
                // Calculate level based on parent hierarchy
                var level = 0
                var currentParentId = task.parent_id
                while (currentParentId) {
                    level++
                    var parentTask = tasksData.find(function(t) { return t.id === currentParentId })
                    if (!parentTask) break
                    currentParentId = parentTask.parent_id
                }
                
                taskListModel.append({
                    taskId: task.id,
                    taskName: task.name,
                    taskType: task.type,
                    taskStatus: task.status,
                    taskProgress: task.progress || 0,
                    taskDescription: task.description || "",
                    parentId: task.parent_id || "",
                    isExpanded: false,
                    level: level,
                    hasChildren: task.children && task.children.length > 0
                })
            }
        }
    }
    
    function addChildrenToModel(parentId, parentIndex, level) {
        var parent = tasksData.find(function(t) { return t.id === parentId })
        if (!parent || !parent.children || parent.children.length === 0) {
            return
        }
        
        var insertIndex = parentIndex + 1
        for (var i = 0; i < parent.children.length; i++) {
            var childId = parent.children[i]
            var child = tasksData.find(function(t) { return t.id === childId })
            
            if (child) {
                taskListModel.insert(insertIndex, {
                    taskId: child.id,
                    taskName: child.name,
                    taskType: child.type,
                    taskStatus: child.status,
                    taskProgress: child.progress || 0,
                    taskDescription: child.description || "",
                    parentId: child.parent_id || "",
                    isExpanded: false,
                    level: level + 1,
                    hasChildren: child.children && child.children.length > 0
                })
                insertIndex++
            }
        }
    }
    
    function removeChildrenFromModel(parentId, startIndex) {
        // Remove all descendants of the given parent recursively
        var i = startIndex + 1
        while (i < taskListModel.count) {
            var item = taskListModel.get(i)
            var task = tasksData.find(function(t) { return t.id === item.taskId })
            
            // Check if this task is a descendant of parentId
            if (task && isDescendant(task.id, parentId)) {
                taskListModel.remove(i)
                // Don't increment i since we removed an item
            } else {
                // If we hit a task that's not a descendant, we're done
                break
            }
        }
    }
    
    function isDescendant(taskId, ancestorId) {
        var task = tasksData.find(function(t) { return t.id === taskId })
        if (!task) return false
        
        var currentParentId = task.parent_id
        while (currentParentId) {
            if (currentParentId === ancestorId) {
                return true
            }
            var parentTask = tasksData.find(function(t) { return t.id === currentParentId })
            if (!parentTask) break
            currentParentId = parentTask.parent_id
        }
        return false
    }
    
    function getChildTypeForParent(parentType) {
        if (parentType === "Epic") return "Feature"
        if (parentType === "Feature") return "PBI"
        if (parentType === "PBI") return "Task"
        return ""
    }
    
    function getColorForTaskType(taskType) {
        if (taskType === "Epic") return "#8b5cf6"      // Purple
        if (taskType === "Feature") return "#3b82f6"   // Blue
        if (taskType === "PBI") return "#10b981"       // Green
        if (taskType === "Task") return "#f59e0b"      // Amber
        return "#6b7280"                                 // Gray
    }
    
    function collapseAll() {
        // Set all items to not expanded
        for (var i = 0; i < taskListModel.count; i++) {
            taskListModel.setProperty(i, "isExpanded", false)
        }
        // Reload to show only items of current type
        refreshTaskList()
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
    
    // Main content
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
                    screenLoader.loadScreen("Screens/ProjectScreen.qml")
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { mouse.accepted = false }
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: "Task Definitions"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
            
            // Task Mode Dropdown
            ComboBox {
                id: taskModeCombo
                Layout.preferredWidth: 150
                Layout.preferredHeight: 40
                model: ["Epic", "Feature", "PBI", "Task"]
                currentIndex: 0
                
                contentItem: Text {
                    text: taskModeCombo.displayText
                    font.pixelSize: 14
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
                        font.pixelSize: 14
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
                    refreshTaskList()
                }
            }
            
            // Collapse All Button
            Button {
                Layout.preferredWidth: 120
                Layout.preferredHeight: 40
                text: "Collapse All"
                
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
                    collapseAll()
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { mouse.accepted = false }
                }
            }
        }
        
        // Task list
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
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Text {
                        Layout.fillWidth: true
                        text: currentMode + " List"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }
                    
                    Button {
                        Layout.preferredWidth: 120
                        Layout.preferredHeight: 36
                        text: "+ Add " + currentMode
                        
                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 13
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            radius: 10
                            color: parent.pressed ? "#5558e3" : (parent.hovered ? "#7c7df7" : "#6366f1")
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }
                        
                        onClicked: {
                            addTaskDialog.open()
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: function(mouse) { mouse.accepted = false }
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
                        spacing: 10
                        
                        delegate: Rectangle {
                            width: taskListView.width
                            height: 80
                            color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                            radius: 12
                            border.color: taskMouseArea.containsMouse ? getColorForTaskType(model.taskType) : "transparent"
                            border.width: 3
                            
                            // Left color indicator strip
                            Rectangle {
                                width: 6
                                height: parent.height
                                anchors.left: parent.left
                                radius: 12
                                color: getColorForTaskType(model.taskType)
                            }
                            
                            Behavior on border.color { ColorAnimation { duration: 200 } }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 15
                                
                                // Expand/Collapse button
                                Rectangle {
                                    Layout.preferredWidth: 32
                                    Layout.preferredHeight: 32
                                    radius: 16
                                    color: model.hasChildren ? Qt.rgba(0.3, 0.3, 0.4, 0.5) : Qt.rgba(0.2, 0.2, 0.25, 0.3)
                                    visible: true
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: model.isExpanded ? "▼" : "▶"
                                        font.pixelSize: 14
                                        color: model.hasChildren ? "white" : "#6b7280"
                                        opacity: model.hasChildren ? 1.0 : 0.5
                                    }
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: model.hasChildren ? Qt.PointingHandCursor : Qt.ArrowCursor
                                        onClicked: {
                                            if (!model.hasChildren) return
                                            
                                            var expanded = !model.isExpanded
                                            taskListModel.setProperty(index, "isExpanded", expanded)
                                            
                                            if (expanded) {
                                                addChildrenToModel(model.taskId, index, model.level)
                                            } else {
                                                removeChildrenFromModel(model.taskId, index)
                                            }
                                        }
                                    }
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 4
                                    
                                    Text {
                                        text: model.taskName
                                        font.pixelSize: 16
                                        font.bold: true
                                        color: "white"
                                    }
                                    
                                    RowLayout {
                                        spacing: 10
                                        
                                        Rectangle {
                                            width: 60
                                            height: 20
                                            radius: 10
                                            color: Qt.rgba(0.39, 0.40, 0.95, 0.3)
                                            
                                            Text {
                                                anchors.centerIn: parent
                                                text: model.taskType
                                                font.pixelSize: 10
                                                font.bold: true
                                                color: "#a5b4fc"
                                            }
                                        }
                                        
                                        Text {
                                            text: "Status: " + model.taskStatus
                                            font.pixelSize: 12
                                            color: "#94a3b8"
                                        }
                                    }
                                }
                                
                                Text {
                                    text: model.taskProgress + "%"
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "#22c55e"
                                }
                                
                                // Add Child button
                                Rectangle {
                                    Layout.preferredWidth: 36
                                    Layout.preferredHeight: 36
                                    radius: 18
                                    color: addChildMouseArea.containsMouse ? "#6366f1" : Qt.rgba(0.39, 0.40, 0.95, 0.3)
                                    visible: model.taskType !== "Task"  // Task is leaf node, can't have children
                                    
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                    
                                    Text {
                                        anchors.centerIn: parent
                                        text: "+"
                                        font.pixelSize: 20
                                        font.bold: true
                                        color: "white"
                                    }
                                    
                                    MouseArea {
                                        id: addChildMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            selectedParentId = model.taskId
                                            var childType = getChildTypeForParent(model.taskType)
                                            addTaskDialog.dialogTitle = "Add " + childType + " to " + model.taskName
                                            addTaskDialog.open()
                                        }
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: taskMouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                z: -1
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
    
    // Add Task Dialog
    Dialog {
        id: addTaskDialog
        modal: true
        anchors.centerIn: parent
        width: 450
        height: 620
        
        property string dialogTitle: "Add " + currentMode
        
        function calculateEndDate(startDateStr, estimatedDays) {
            if (!startDateStr || !estimatedDays || estimatedDays <= 0) return ""
            
            var startDate = new Date(startDateStr)
            var daysAdded = 0
            var currentDate = new Date(startDate)
            
            while (daysAdded < estimatedDays) {
                currentDate.setDate(currentDate.getDate() + 1)
                // Skip weekends (0 = Sunday, 6 = Saturday)
                var dayOfWeek = currentDate.getDay()
                if (dayOfWeek !== 0 && dayOfWeek !== 6) {
                    daysAdded++
                }
            }
            
            return Qt.formatDate(currentDate, "yyyy-MM-dd")
        }
        
        header: Rectangle {
            width: parent.width
            height: 50
            color: "#1f2937"
            radius: 12
            
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: parent.radius
                color: parent.color
            }
            
            Text {
                anchors.centerIn: parent
                text: addTaskDialog.dialogTitle
                font.pixelSize: 16
                font.bold: true
                color: "white"
            }
        }
        
        background: Rectangle {
            color: "#1f2937"
            radius: 12
            border.color: "#374151"
            border.width: 1
        }
        
        contentItem: Item {
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15
                
                Text {
                    text: "Task Name:"
                    font.pixelSize: 14
                    color: "white"
                }
                
                TextField {
                    id: taskNameField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: "Enter task name"
                    color: "white"
                    leftPadding: 12
                    rightPadding: 12
                    
                    background: Rectangle {
                        color: "#374151"
                        radius: 6
                    }
                }
                
                Text {
                    text: "Description:"
                    font.pixelSize: 14
                    color: "white"
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    clip: true
                    
                    TextArea {
                        id: taskDescField
                        width: parent.width
                        placeholderText: "Enter description"
                        color: "white"
                        wrapMode: TextArea.Wrap
                        padding: 12
                        
                        background: Rectangle {
                            color: "#374151"
                            radius: 6
                        }
                    }
                }
                
                Text {
                    text: "Estimated Days (work days):"
                    font.pixelSize: 14
                    color: "white"
                }
                
                TextField {
                    id: estimatedDaysField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    placeholderText: "Enter estimated work days"
                    color: "white"
                    leftPadding: 12
                    rightPadding: 12
                    validator: IntValidator { bottom: 0; top: 999 }
                    
                    background: Rectangle {
                        color: "#374151"
                        radius: 6
                    }
                    
                    onTextChanged: {
                        if (text && startDateField.text) {
                            var calculated = addTaskDialog.calculateEndDate(startDateField.text, parseInt(text))
                            if (calculated) {
                                endDateField.text = calculated
                            }
                        }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "Start Date:"
                            font.pixelSize: 14
                            color: "white"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            TextField {
                                id: startDateField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "YYYY-MM-DD"
                                color: "white"
                                leftPadding: 12
                                rightPadding: 12
                                readOnly: true
                                
                                background: Rectangle {
                                    color: "#374151"
                                    radius: 6
                                }
                                
                                onTextChanged: {
                                    if (text && estimatedDaysField.text) {
                                        var estimated = parseInt(estimatedDaysField.text)
                                        if (estimated > 0) {
                                            var calculated = addTaskDialog.calculateEndDate(text, estimated)
                                            if (calculated) {
                                                endDateField.text = calculated
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Button {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                text: "📅"
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 18
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    color: parent.hovered ? "#4b5563" : "#374151"
                                    radius: 6
                                }
                                
                                onClicked: startDateDialog.open()
                            }
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 5
                        
                        Text {
                            text: "End Date:"
                            font.pixelSize: 14
                            color: "white"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 5
                            
                            TextField {
                                id: endDateField
                                Layout.fillWidth: true
                                Layout.preferredHeight: 40
                                placeholderText: "YYYY-MM-DD"
                                color: "white"
                                leftPadding: 12
                                rightPadding: 12
                                readOnly: true
                                enabled: !estimatedDaysField.text || estimatedDaysField.text === ""
                                
                                background: Rectangle {
                                    color: enabled ? "#374151" : "#2d3748"
                                    radius: 6
                                }
                            }
                            
                            Button {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                text: "📅"
                                enabled: !estimatedDaysField.text || estimatedDaysField.text === ""
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 18
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                    opacity: parent.enabled ? 1.0 : 0.4
                                }
                                
                                background: Rectangle {
                                    color: parent.enabled ? (parent.hovered ? "#4b5563" : "#374151") : "#2d3748"
                                    radius: 6
                                }
                                
                                onClicked: endDateDialog.open()
                            }
                        }
                    }
                }
                
                Item {
                    Layout.fillHeight: true
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10
                    
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        text: "Cancel"
                        onClicked: {
                            taskNameField.text = ""
                            taskDescField.text = ""
                            estimatedDaysField.text = ""
                            startDateField.text = ""
                            endDateField.text = ""
                            selectedParentId = ""
                            addTaskDialog.close()
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? "#4b5563" : "#374151"
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }
                    }
                    
                    Button {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        text: "Create"
                        onClicked: {
                            if (taskNameField.text.trim() !== "") {
                                // If selectedParentId is set, create as child; otherwise use currentMode as top-level
                                var taskType = selectedParentId !== "" ? getChildTypeForParent(
                                    tasksData.find(function(t) { return t.id === selectedParentId }).type
                                ) : currentMode
                                
                                taskManager.createTask(
                                    taskType, 
                                    taskNameField.text, 
                                    taskDescField.text, 
                                    selectedParentId,
                                    estimatedDaysField.text || "0",
                                    startDateField.text || "",
                                    endDateField.text || ""
                                )
                                taskNameField.text = ""
                                taskDescField.text = ""
                                estimatedDaysField.text = ""
                                startDateField.text = ""
                                endDateField.text = ""
                                selectedParentId = ""
                                addTaskDialog.close()
                                loadTasks()
                            }
                        }
                        
                        background: Rectangle {
                            color: parent.hovered ? "#5558e3" : "#6366f1"
                            radius: 6
                        }
                        
                        contentItem: Text {
                            text: parent.text
                            color: "white"
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            font.pixelSize: 14
                        }
                    }
                }
            }
        }
    }
    
    // Start Date Calendar
    Calendar {
        id: startDateDialog
        title: "Select Start Date"
        anchors.centerIn: parent
        
        onDateSelected: function(date) {
            startDateField.text = date
        }
    }
    
    // End Date Calendar
    Calendar {
        id: endDateDialog
        title: "Select End Date"
        anchors.centerIn: parent
        
        onDateSelected: function(date) {
            endDateField.text = date
        }
    }
    
    // Connections to TaskManager
    Connections {
        target: taskManager
        
        function onTaskCreated() {
            loadTasks()
        }
    }
}
