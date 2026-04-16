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
                    screenLoader.loadScreen("Screens/ProjectListScreen.qml")
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onPressed: function(mouse) { mouse.accepted = false }
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: "Project Dashboard"
                font.pixelSize: 32
                font.bold: true
                color: "white"
            }
        }
        
        // Action buttons
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            GridLayout {
                anchors.centerIn: parent
                columns: 2
                columnSpacing: 40
                rowSpacing: 40
                
                // Task Definition button
                Rectangle {
                    Layout.preferredWidth: 340
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: taskDefArea.containsMouse ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    
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
                                text: "📋"
                                font.pixelSize: 50
                            }
                            
                            scale: taskDefArea.containsMouse ? 1.1 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Task Definition"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 280
                            text: "Define and manage project tasks hierarchy"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: taskDefArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            screenLoader.loadScreen("Screens/TaskDefinitionScreen.qml")
                        }
                    }
                }
                
                // Gantt Chart button
                Rectangle {
                    Layout.preferredWidth: 340
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: ganttArea.containsMouse ? "#10b981" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    
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
                                text: "📊"
                                font.pixelSize: 50
                            }
                            
                            scale: ganttArea.containsMouse ? 1.1 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Gantt Chart"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 280
                            text: "View project timeline and dependencies"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: ganttArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            screenLoader.loadScreen("Screens/GanttChartScreen.qml")
                        }
                    }
                }
            }
        }
    }
}
