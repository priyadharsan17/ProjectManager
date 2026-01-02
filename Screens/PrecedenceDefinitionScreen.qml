import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    color: "#0a0a0a"
    
    property string currentMode: "Epic"
    property var tasksData: []
    
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
                taskListModel.append({
                    taskId: task.id,
                    taskName: task.name,
                    taskType: task.type,
                    taskStatus: task.status
                })
            }
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
                Layout.preferredWidth: parent.width * 0.35
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
                                refreshTaskList()
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
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Sheet View\n\nTask dependencies will be displayed here in table format"
                                font.pixelSize: 16
                                color: "#6b7280"
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                        
                        // Link Diagram View
                        Rectangle {
                            color: "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: "Link Diagram View\n\nTask dependency diagram will be displayed here"
                                font.pixelSize: 16
                                color: "#6b7280"
                                horizontalAlignment: Text.AlignHCenter
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
}
