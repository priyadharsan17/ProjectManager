import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    color: "#0a0a0a"
    
    property var projects: []
    
    Component.onCompleted: {
        loadProjects()
    }
    
    function loadProjects() {
        var projectsJson = projectManager.getProjectList()
        projects = JSON.parse(projectsJson)
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
        spacing: 30
        
        // Header with back button
        RowLayout {
            Layout.fillWidth: true
            spacing: 20
            
            // Back button
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
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }
                
                onClicked: {
                    screenLoader.loadHomeScreen()
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { mouse.accepted = false }
                }
            }
            
            // Title
            Text {
                Layout.fillWidth: true
                text: "Open Project"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
        }
        
        // Projects list
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Qt.rgba(0.08, 0.08, 0.12, 0.95)
            radius: 20
            border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
            border.width: 1
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 30
                spacing: 20
                
                Text {
                    text: projects.length === 0 ? "No projects found" : "Select a project to open"
                    font.pixelSize: 16
                    color: "#94a3b8"
                }
                
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    
                    GridLayout {
                        width: parent.width
                        columns: 3
                        columnSpacing: 20
                        rowSpacing: 20
                        
                        Repeater {
                            model: projects
                            
                            Rectangle {
                                Layout.preferredWidth: 280
                                Layout.preferredHeight: 220
                                color: Qt.rgba(0.15, 0.15, 0.2, 0.8)
                                radius: 16
                                border.color: projectMouseArea.containsMouse ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                                border.width: 2
                                
                                Behavior on border.color {
                                    ColorAnimation { duration: 200 }
                                }
                                
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    shadowEnabled: true
                                    shadowColor: "#40000000"
                                    shadowBlur: 0.3
                                    shadowVerticalOffset: 10
                                }
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 24
                                    spacing: 16
                                    
                                    Rectangle {
                                        Layout.alignment: Qt.AlignHCenter
                                        width: 60
                                        height: 60
                                        radius: 30
                                        gradient: Gradient {
                                            GradientStop { position: 0.0; color: "#10b981" }
                                            GradientStop { position: 1.0; color: "#059669" }
                                        }
                                        
                                        Text {
                                            anchors.centerIn: parent
                                            text: "📁"
                                            font.pixelSize: 32
                                        }
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: modelData.name
                                        font.pixelSize: 18
                                        font.bold: true
                                        color: "white"
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Manager: " + modelData.manager
                                        font.pixelSize: 13
                                        color: "#94a3b8"
                                        horizontalAlignment: Text.AlignHCenter
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        Layout.fillWidth: true
                                        text: "Status: " + modelData.status
                                        font.pixelSize: 12
                                        color: modelData.status === "Active" ? "#22c55e" : "#94a3b8"
                                        horizontalAlignment: Text.AlignHCenter
                                    }
                                }
                                
                                MouseArea {
                                    id: projectMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        // Set current project folder
                                        projectManager.setCurrentProjectFolder(modelData.folder_path)
                                        // Load project tasks and navigate to project screen
                                        taskManager.loadProjectTasks(modelData.folder_path)
                                        screenLoader.loadScreen("Screens/ProjectScreen.qml")
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
