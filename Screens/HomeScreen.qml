import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

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
        spacing: 40
        
        // Header section
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 80
            color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
            radius: 16
            border.color: Qt.rgba(0.3, 0.3, 0.4, 0.3)
            border.width: 1
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                anchors.topMargin: 15
                anchors.bottomMargin: 15
                spacing: 20
                
                // Profile icon
                Rectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    radius: 25
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#6366f1" }
                        GradientStop { position: 1.0; color: "#8b5cf6" }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: loginManager.currentUser ? loginManager.currentUser.charAt(0).toUpperCase() : "U"
                        font.pixelSize: 22
                        font.bold: true
                        color: "white"
                    }
                }
                
                // Welcome text
                ColumnLayout {
                    spacing: 2
                    
                    Text {
                        text: "Welcome back!"
                        font.pixelSize: 14
                        color: "#94a3b8"
                    }
                    
                    Text {
                        text: loginManager.currentUser || "User"
                        font.pixelSize: 20
                        font.bold: true
                        color: "white"
                    }
                }
                
                // Spacer to push logout button to the right
                Item {
                    Layout.fillWidth: true
                }
                
                // Logout button
                Button {
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 40
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    text: "Logout"
                    
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
                        color: parent.pressed ? "#dc2626" : (parent.hovered ? "#ef4444" : "#f87171")
                        
                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }
                    }
                    
                    onClicked: {
                        loginManager.logout()
                        screenLoader.loadLoginScreen()
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPressed: function(mouse) { mouse.accepted = false }
                    }
                }
            }
        }
        
        // Main action buttons section
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GridLayout {
                anchors.centerIn: parent
                columns: 3
                columnSpacing: 40
                rowSpacing: 40
                
                // Create Project button
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: createProjectArea.containsMouse ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.4
                        shadowVerticalOffset: 15
                    }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 24
                        
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            radius: 50
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#6366f1" }
                                GradientStop { position: 1.0; color: "#8b5cf6" }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 56
                                font.bold: true
                                color: "white"
                            }
                            
                            scale: createProjectArea.containsMouse ? 1.1 : 1.0
                            
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Create Project"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 240
                            text: "Start a new project from scratch"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: createProjectArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Create Project clicked")
                            // TODO: Implement create project functionality
                        }
                    }
                }
                
                // Open Project button
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: openProjectArea.containsMouse ? "#10b981" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.4
                        shadowVerticalOffset: 15
                    }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 24
                        
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            radius: 50
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#10b981" }
                                GradientStop { position: 1.0; color: "#059669" }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "📁"
                                font.pixelSize: 50
                            }
                            
                            scale: openProjectArea.containsMouse ? 1.1 : 1.0
                            
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Open Project"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 240
                            text: "Continue working on existing projects"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: openProjectArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Open Project clicked")
                            // TODO: Implement open project functionality
                        }
                    }
                }
                
                // Settings button
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: settingsArea.containsMouse ? "#f59e0b" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: "#40000000"
                        shadowBlur: 0.4
                        shadowVerticalOffset: 15
                    }
                    
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 24
                        
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            radius: 50
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#f59e0b" }
                                GradientStop { position: 1.0; color: "#d97706" }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "⚙"
                                font.pixelSize: 50
                            }
                            
                            scale: settingsArea.containsMouse ? 1.1 : 1.0
                            rotation: settingsArea.containsMouse ? 90 : 0
                            
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                            
                            Behavior on rotation {
                                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Settings"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 240
                            text: "Configure app preferences and options"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: settingsArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            console.log("Settings clicked")
                            // TODO: Implement settings functionality
                        }
                    }
                }
            }
        }
    }
}
