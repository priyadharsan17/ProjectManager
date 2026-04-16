import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1280
    height: 720
    minimumWidth: 800
    minimumHeight: 600
    title: "Project Manager"
    
    Loader { id: themeLoader; source: "qrc:/Screens/Theme.qml"; asynchronous: false }

    // Remove default window frame for modern look (optional)
    flags: Qt.Window | Qt.FramelessWindowHint
    color: "transparent"
    
    // Main content loader
        Loader { 
        id: contentLoader
        anchors.fill: parent
        source: screenLoader.currentScreen
    }

    // Optional: Add window controls for frameless window
    Rectangle {
        id: titleBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 32
        color: "transparent"
        z: 999
        
        MouseArea {
            anchors.fill: parent
            property point lastMousePos: Qt.point(0, 0)
            onPressed: {
                lastMousePos = Qt.point(mouseX, mouseY)
            }
            onMouseXChanged: {
                if (pressed) {
                    mainWindow.x += (mouseX - lastMousePos.x)
                }
            }
            onMouseYChanged: {
                if (pressed) {
                    mainWindow.y += (mouseY - lastMousePos.y)
                }
            }
        }
        
        // Window controls
        Row {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 8
            spacing: 8
            
            // Minimize button
            Rectangle {
                width: 32
                height: 32
                radius: 6
                color: minimizeArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "−"
                    font.pixelSize: 18
                    color: "white"
                }
                
                MouseArea {
                    id: minimizeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: mainWindow.showMinimized()
                }
            }
            
            // Maximize/Restore button
            Rectangle {
                width: 32
                height: 32
                radius: 6
                color: maximizeArea.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: mainWindow.visibility === Window.Maximized ? "◱" : "□"
                    font.pixelSize: 14
                    color: "white"
                }
                
                MouseArea {
                    id: maximizeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (mainWindow.visibility === Window.Maximized) {
                            mainWindow.showNormal()
                        } else {
                            mainWindow.showMaximized()
                        }
                    }
                }
            }
            
            // Close button
            Rectangle {
                width: 32
                height: 32
                radius: 6
                color: closeArea.containsMouse ? themeLoader.item.error : "transparent"
                
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    font.pixelSize: 16
                    color: "white"
                }
                
                MouseArea {
                    id: closeArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Qt.quit()
                }
            }
        }
    }

    // Function to switch screens
    function loadScreen(screenPath) {
        contentLoader.source = screenPath
    }
    
    // Connection to ScreenLoader for managing screen transitions
    Connections {
        target: screenLoader
        
        function onScreenChanged(screenPath) {
            contentLoader.source = screenPath
        }
    }
   
}
