import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects
import QtQuick.Dialogs

Rectangle {
    id: root
    color: "#0a0a0a"
    
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
                text: "Back"
                
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
                text: "Create New Project"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
        }
        
        // Form container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Rectangle {
                width: 600
                height: 600
                anchors.centerIn: parent
                color: Qt.rgba(0.08, 0.08, 0.12, 0.95)
                radius: 24
                border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
                border.width: 1
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: "#80000000"
                    shadowBlur: 0.4
                    shadowVerticalOffset: 20
                    shadowHorizontalOffset: 0
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 40
                    spacing: 30
                    
                    // Icon and description
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12
                        
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 80
                            height: 80
                            radius: 40
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#6366f1" }
                                GradientStop { position: 1.0; color: "#8b5cf6" }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 48
                                font.bold: true
                                color: "white"
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Fill in the project details below"
                            font.pixelSize: 14
                            color: "#94a3b8"
                        }
                    }
                    
                    // Project Name field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Project Name"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#cbd5e1"
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                            radius: 12
                            border.color: projectNameField.activeFocus ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                            border.width: 2
                            
                            Behavior on border.color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            TextField {
                                id: projectNameField
                                anchors.fill: parent
                                anchors.margins: 2
                                placeholderText: "Enter project name"
                                placeholderTextColor: "#64748b"
                                color: "white"
                                font.pixelSize: 15
                                leftPadding: 16
                                background: Rectangle {
                                    color: "transparent"
                                }
                                
                                Keys.onReturnPressed: managerNameField.forceActiveFocus()
                            }
                        }
                    }
                    
                    // Project Manager field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Project Manager"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#cbd5e1"
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                            radius: 12
                            border.color: managerNameField.activeFocus ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                            border.width: 2
                            
                            Behavior on border.color {
                                ColorAnimation { duration: 200 }
                            }
                            
                            TextField {
                                id: managerNameField
                                anchors.fill: parent
                                anchors.margins: 2
                                placeholderText: "Enter project manager name"
                                placeholderTextColor: "#64748b"
                                color: "white"
                                font.pixelSize: 15
                                leftPadding: 16
                                background: Rectangle {
                                    color: "transparent"
                                }
                                
                                Keys.onReturnPressed: createButton.clicked()
                            }
                        }
                    }
                    
                    // Project Folder field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        
                        Text {
                            text: "Project Folder"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: "#cbd5e1"
                        }
                        
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10
                            
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 48
                                color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                                radius: 12
                                border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
                                border.width: 2
                                
                                TextField {
                                    id: projectFolderField
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    placeholderText: "Select project folder location"
                                    placeholderTextColor: "#64748b"
                                    color: "white"
                                    font.pixelSize: 15
                                    leftPadding: 16
                                    readOnly: true
                                    background: Rectangle {
                                        color: "transparent"
                                    }
                                    
                                    Component.onCompleted: {
                                        // Set default folder path based on workspace and project name
                                        updateDefaultFolder()
                                    }
                                }
                            }
                            
                            Button {
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 48
                                text: "Browse..."
                                
                                contentItem: Text {
                                    text: parent.text
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    verticalAlignment: Text.AlignVCenter
                                }
                                
                                background: Rectangle {
                                    radius: 12
                                    color: parent.pressed ? "#4b5563" : (parent.hovered ? "#6b7280" : "#374151")
                                    
                                    Behavior on color {
                                        ColorAnimation { duration: 200 }
                                    }
                                }
                                
                                onClicked: {
                                    folderDialog.open()
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onPressed: function(mouse) { mouse.accepted = false }
                                }
                            }
                        }
                    }
                    
                    // Status message
                    Text {
                        id: statusMessage
                        Layout.fillWidth: true
                        Layout.preferredHeight: 20
                        text: ""
                        font.pixelSize: 13
                        color: "#ef4444"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    
                    // Create button
                    Button {
                        id: createButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        text: "Create Project"
                        
                        contentItem: Text {
                            text: createButton.text
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: createButton.pressed ? "#5558e3" : "#6366f1" }
                                GradientStop { position: 1.0; color: createButton.pressed ? "#7c3aed" : "#8b5cf6" }
                            }
                            
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                            
                            scale: createButton.pressed ? 0.98 : 1.0
                        }
                        
                        onClicked: {
                            if (projectNameField.text === "" || managerNameField.text === "") {
                                statusMessage.text = "Please fill in all fields"
                                statusMessage.color = "#ef4444"
                                return
                            }
                            
                            if (projectFolderField.text === "") {
                                statusMessage.text = "Please select a project folder"
                                statusMessage.color = "#ef4444"
                                return
                            }
                            
                            statusMessage.text = "Creating project..."
                            statusMessage.color = "#3b82f6"
                            projectManager.createProject(projectNameField.text, managerNameField.text, projectFolderField.text)
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: function(mouse) { mouse.accepted = false }
                        }
                    }
                    
                    Item {
                        Layout.fillHeight: true
                    }
                }
            }
        }
    }
    
    // Connections to ProjectManager
    Connections {
        target: projectManager
        
        function onProjectCreated(projectName, managerName, folderPath) {
            statusMessage.text = "Project created successfully!"
            statusMessage.color = "#22c55e"
            
            // Clear fields after successful creation
            projectNameField.text = ""
            managerNameField.text = ""
            projectFolderField.text = ""
            
            // Navigate back to home screen after a short delay
            backTimer.start()
        }
        
        function onProjectCreationFailed(errorMessage) {
            statusMessage.text = errorMessage
            statusMessage.color = "#ef4444"
        }
        
        function onProjectStatusChanged(status) {
            if (status.indexOf("Creating") !== -1) {
                statusMessage.text = status
                statusMessage.color = "#3b82f6"
            }
        }
    }
    
    // Folder dialog for selecting project location
    FolderDialog {
        id: folderDialog
        title: "Select Project Folder"
        currentFolder: projectManager.getWorkspaceDirectory()
        
        onAccepted: {
            projectFolderField.text = folderDialog.selectedFolder.toString().replace("file:///", "")
        }
    }
    
    // Function to update default folder based on project name and workspace
    function updateDefaultFolder() {
        if (projectNameField.text !== "") {
            var workspaceDir = projectManager.getWorkspaceDirectory()
            var projectName = projectNameField.text.trim().replace(/[^a-zA-Z0-9]/g, "_")
            projectFolderField.text = workspaceDir + "/" + projectName
        }
    }
    
    // Update folder when project name changes
    Connections {
        target: projectNameField
        function onTextChanged() {
            if (projectFolderField.text === "" || projectFolderField.text.indexOf(projectManager.getWorkspaceDirectory()) === 0) {
                updateDefaultFolder()
            }
        }
    }
    
    // Timer to go back to home screen after successful creation
    Timer {
        id: backTimer
        interval: 2000
        running: false
        repeat: false
        onTriggered: {
            screenLoader.loadHomeScreen()
        }
    }
}
