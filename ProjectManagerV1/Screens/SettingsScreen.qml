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
                text: "Settings"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
        }
        
        // Settings container
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            Rectangle {
                width: 700
                height: 500
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
                                GradientStop { position: 0.0; color: "#f59e0b" }
                                GradientStop { position: 1.0; color: "#d97706" }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⚙"
                                font.pixelSize: 48
                                color: "white"
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Application Settings"
                            font.pixelSize: 20
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Configure workspace and preferences"
                            font.pixelSize: 14
                            color: "#94a3b8"
                        }
                    }
                    
                    // Workspace Directory setting
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 12
                        
                        Text {
                            text: "Workspace Directory"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: "#cbd5e1"
                        }
                        
                        Text {
                            Layout.fillWidth: true
                            text: "All project folders will be created in this directory"
                            font.pixelSize: 12
                            color: "#94a3b8"
                            wrapMode: Text.WordWrap
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
                                    id: workspaceDirField
                                    anchors.fill: parent
                                    anchors.margins: 2
                                    placeholderText: "Select workspace directory"
                                    placeholderTextColor: "#64748b"
                                    color: "white"
                                    font.pixelSize: 14
                                    leftPadding: 16
                                    readOnly: true
                                    text: settingsManager.workspaceDirectory
                                    background: Rectangle {
                                        color: "transparent"
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
                                    workspaceFolderDialog.open()
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
                        color: "#22c55e"
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                    }
                    
                    Item {
                        Layout.fillHeight: true
                        Layout.minimumHeight: 10
                    }
                    
                    // Save button
                    Button {
                        id: saveButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52
                        Layout.alignment: Qt.AlignBottom
                        text: "Save Settings"
                        
                        contentItem: Text {
                            text: saveButton.text
                            font.pixelSize: 16
                            font.bold: true
                            color: "white"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: saveButton.pressed ? "#d97706" : "#f59e0b" }
                                GradientStop { position: 1.0; color: saveButton.pressed ? "#b45309" : "#d97706" }
                            }
                            
                            Behavior on scale {
                                NumberAnimation { duration: 100 }
                            }
                            
                            scale: saveButton.pressed ? 0.98 : 1.0
                        }
                        
                        onClicked: {
                            if (workspaceDirField.text === "") {
                                statusMessage.text = "Please select a workspace directory"
                                statusMessage.color = "#ef4444"
                                return
                            }
                            
                            settingsManager.setWorkspaceDirectory(workspaceDirField.text)
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: function(mouse) { mouse.accepted = false }
                        }
                    }
                }
            }
        }
    }
    
    // Folder dialog for selecting workspace directory
    FolderDialog {
        id: workspaceFolderDialog
        title: "Select Workspace Directory"
        currentFolder: settingsManager.workspaceDirectory
        
        onAccepted: {
            workspaceDirField.text = workspaceFolderDialog.selectedFolder.toString().replace("file:///", "")
        }
    }
    
    // Connections to SettingsManager
    Connections {
        target: settingsManager
        
        function onSettingsSaved() {
            statusMessage.text = "Settings saved successfully!"
            statusMessage.color = "#22c55e"
            
            // Notify ProjectManager to refresh workspace directory
            projectManager.refreshWorkspaceDirectory()
            
            // Auto-hide message after 3 seconds
            messageTimer.start()
        }
        
        function onSettingsSaveFailed(errorMessage) {
            statusMessage.text = errorMessage
            statusMessage.color = "#ef4444"
        }
    }
    
    // Timer to hide status message
    Timer {
        id: messageTimer
        interval: 3000
        running: false
        repeat: false
        onTriggered: {
            statusMessage.text = ""
        }
    }
}
