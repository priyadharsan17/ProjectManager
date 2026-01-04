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
    property date startDate: new Date()
    property date endDate: new Date()
    
    Component.onCompleted: {
        loadTasks()
        calculateDateRange()
    }
    
    function loadTasks() {
        var allTasks = JSON.parse(taskManager.getAllTasks())
        tasksData = allTasks
        refreshTaskList()
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
    }
    
    function refreshTaskList() {
        chartTaskModel.clear()
        
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
            
            chartTaskModel.append({
                taskId: task.id,
                taskName: task.name,
                taskType: task.type,
                taskStatus: task.status,
                startDate: task.start_date || "",
                endDate: task.end_date || "",
                estimatedDays: task.estimated_days || 0
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
                
                model: ListModel { id: parentListModel }
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
                    width: Math.max(timelineContent.width, parent.parent.width - 40)
                    height: Math.max(timelineContent.height, parent.parent.height - 40)
                    
                    Column {
                        id: timelineContent
                        spacing: 0
                        
                        // Timeline tasks
                        Repeater {
                            model: ListModel { id: chartTaskModel }
                            
                            Rectangle {
                                width: 1800
                                height: 80
                                color: index % 2 === 0 ? Qt.rgba(0.12, 0.12, 0.16, 0.8) : Qt.rgba(0.15, 0.15, 0.2, 0.8)
                                
                                RowLayout {
                                    anchors.fill: parent
                                    spacing: 0
                                    
                                    // Task name column (fixed width)
                                    Rectangle {
                                        Layout.preferredWidth: 250
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        border.color: "#374151"
                                        border.width: 1
                                        
                                        RowLayout {
                                            anchors.fill: parent
                                            anchors.margins: 10
                                            spacing: 10
                                            
                                            Rectangle {
                                                Layout.preferredWidth: 4
                                                Layout.fillHeight: true
                                                radius: 2
                                                color: getColorForTaskType(model.taskType)
                                            }
                                            
                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 4
                                                
                                                Text {
                                                    Layout.fillWidth: true
                                                    text: model.taskName
                                                    font.pixelSize: 13
                                                    font.bold: true
                                                    color: "white"
                                                    elide: Text.ElideRight
                                                }
                                                
                                                Text {
                                                    text: model.estimatedDays + " days"
                                                    font.pixelSize: 10
                                                    color: "#94a3b8"
                                                }
                                            }
                                        }
                                    }
                                    
                                    // Timeline bars area
                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        color: "transparent"
                                        border.color: "#374151"
                                        border.width: 1
                                        
                                        // Task bar
                                        Rectangle {
                                            x: 50 + (index * 150)  // Position based on task index
                                            y: 15
                                            width: Math.max(model.estimatedDays * 20, 80)  // Width based on duration
                                            height: 50
                                            radius: 8
                                            color: getColorForTaskType(model.taskType)
                                            opacity: 0.8
                                            
                                            ColumnLayout {
                                                anchors.centerIn: parent
                                                spacing: 2
                                                
                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: model.startDate
                                                    font.pixelSize: 9
                                                    color: "white"
                                                    font.bold: true
                                                }
                                                
                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: "→"
                                                    font.pixelSize: 8
                                                    color: "white"
                                                }
                                                
                                                Text {
                                                    Layout.alignment: Qt.AlignHCenter
                                                    text: model.endDate
                                                    font.pixelSize: 9
                                                    color: "white"
                                                    font.bold: true
                                                }
                                            }
                                            
                                            // Hover effect
                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onEntered: parent.opacity = 1.0
                                                onExited: parent.opacity = 0.8
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
    
    // Connections to TaskManager
    Connections {
        target: taskManager
        
        function onTaskCreated() {
            loadTasks()
        }
    }
}
