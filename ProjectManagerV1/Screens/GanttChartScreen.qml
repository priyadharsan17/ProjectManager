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
                text: "Gantt Chart"
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
                
                // Precedence Definition button
                Rectangle {
                    Layout.preferredWidth: 340
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: precedenceArea.containsMouse ? "#f59e0b" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
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
                                GradientStop { position: 0.0; color: "#f59e0b" }
                                GradientStop { position: 1.0; color: "#d97706" }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "🔗"
                                font.pixelSize: 50
                            }
                            
                            scale: precedenceArea.containsMouse ? 1.1 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Precedence Definition"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 280
                            text: "Define task dependencies and relationships"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: precedenceArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            screenLoader.loadScreen("Screens/PrecedenceDefinitionScreen.qml")
                        }
                    }
                }
                
                // Chart button
                Rectangle {
                    Layout.preferredWidth: 340
                    Layout.preferredHeight: 320
                    color: Qt.rgba(0.1, 0.1, 0.15, 0.8)
                    radius: 20
                    border.color: chartArea.containsMouse ? "#10b981" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
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
                                text: "📈"
                                font.pixelSize: 50
                            }
                            
                            scale: chartArea.containsMouse ? 1.1 : 1.0
                            Behavior on scale {
                                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Chart"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 280
                            text: "View Gantt chart with timeline visualization"
                            font.pixelSize: 14
                            color: "#94a3b8"
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }
                    
                    MouseArea {
                        id: chartArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            screenLoader.loadScreen("Screens/ChartViewScreen.qml")
                        }
                    }
                }
            }
        }
    }
}
