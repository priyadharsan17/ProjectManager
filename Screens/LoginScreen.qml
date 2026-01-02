import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    color: "#0a0a0a"
    
    // Animated gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#1a0a2e" }
            GradientStop { position: 0.5; color: "#16213e" }
            GradientStop { position: 1.0; color: "#0f0e17" }
        }
        
        // Animated circles
        Repeater {
            model: 3
            Rectangle {
                width: 200 + index * 100
                height: width
                radius: width / 2
                color: Qt.rgba(0.3, 0.2, 0.8, 0.1)
                border.color: Qt.rgba(0.5, 0.3, 1, 0.2)
                border.width: 2
                x: parent.width * (0.2 + index * 0.3) - width / 2
                y: parent.height * (0.3 + index * 0.2) - height / 2
                
                SequentialAnimation on y {
                    running: true
                    loops: Animation.Infinite
                    NumberAnimation {
                        to: parent.height * (0.3 + index * 0.2) + 50
                        duration: 3000 + index * 500
                        easing.type: Easing.InOutSine
                    }
                    NumberAnimation {
                        to: parent.height * (0.3 + index * 0.2) - 50
                        duration: 3000 + index * 500
                        easing.type: Easing.InOutSine
                    }
                }
            }
        }
    }
    
    // Login container
    Rectangle {
        id: loginContainer
        width: 420
        height: 550
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
            
            // Logo/Title area
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    
                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 60
                        height: 60
                        radius: 30
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#6366f1" }
                            GradientStop { position: 1.0; color: "#8b5cf6" }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "PM"
                            font.pixelSize: 24
                            font.bold: true
                            color: "white"
                        }
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Project Manager"
                        font.pixelSize: 28
                        font.bold: true
                        color: "white"
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Sign in to continue"
                        font.pixelSize: 14
                        color: "#94a3b8"
                    }
                }
            }
            
            // Username field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "Username"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: "#cbd5e1"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                    radius: 12
                    border.color: usernameField.activeFocus ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    TextField {
                        id: usernameField
                        anchors.fill: parent
                        anchors.margins: 2
                        placeholderText: "Enter your username"
                        placeholderTextColor: "#64748b"
                        color: "white"
                        font.pixelSize: 15
                        leftPadding: 16
                        background: Rectangle {
                            color: "transparent"
                        }
                        
                        Keys.onReturnPressed: passwordField.forceActiveFocus()
                    }
                }
            }
            
            // Password field
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: "Password"
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    color: "#cbd5e1"
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: Qt.rgba(0.15, 0.15, 0.2, 0.6)
                    radius: 12
                    border.color: passwordField.activeFocus ? "#6366f1" : Qt.rgba(0.3, 0.3, 0.4, 0.3)
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 2
                        placeholderText: "Enter your password"
                        placeholderTextColor: "#64748b"
                        color: "white"
                        font.pixelSize: 15
                        leftPadding: 16
                        echoMode: TextInput.Password
                        background: Rectangle {
                            color: "transparent"
                        }
                        
                        Keys.onReturnPressed: loginButton.clicked()
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
            
            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 52
                text: "Sign In"
                
                contentItem: Text {
                    text: loginButton.text
                    font.pixelSize: 16
                    font.bold: true
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    radius: 12
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: loginButton.pressed ? "#5558e3" : "#6366f1" }
                        GradientStop { position: 1.0; color: loginButton.pressed ? "#7c3aed" : "#8b5cf6" }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                    
                    scale: loginButton.pressed ? 0.98 : 1.0
                }
                
                onClicked: {
                    if (usernameField.text === "" || passwordField.text === "") {
                        statusMessage.text = "Please fill in all fields"
                        statusMessage.color = "#ef4444"
                        return
                    }
                    
                    statusMessage.text = "Authenticating..."
                    statusMessage.color = "#3b82f6"
                    loginManager.login(usernameField.text, passwordField.text)
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
    
    // Connections to LoginManager
    Connections {
        target: loginManager
        
        function onLoginSuccess(username) {
            statusMessage.text = "Login successful! Welcome " + username
            statusMessage.color = "#22c55e"
            
            // Clear fields after successful login
            usernameField.text = ""
            passwordField.text = ""
            
            // Load home screen after successful login
            screenLoader.loadHomeScreen()
        }
        
        function onLoginFailed(errorMessage) {
            statusMessage.text = errorMessage
            statusMessage.color = "#ef4444"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        
        function onLoginStatusChanged(status) {
            if (status.indexOf("Authenticating") !== -1) {
                statusMessage.text = status
                statusMessage.color = "#3b82f6"
            }
        }
    }
}
