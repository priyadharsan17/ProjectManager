import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    Loader { id: themeLoader; source: "Theme.qml"; asynchronous: false }
    color: themeLoader.item.rootBackground
    
    // Animated gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: themeLoader.item.backgroundGradient0 }
            GradientStop { position: 0.5; color: themeLoader.item.backgroundGradient1 }
            GradientStop { position: 1.0; color: themeLoader.item.backgroundGradient2 }
        }
    }
    
    // Login container
    Rectangle {
        id: loginContainer
        width: 420
        height: 550
        anchors.centerIn: parent
        color: themeLoader.item.containerBackground
        radius: 24
        border.color: themeLoader.item.containerBorder
        border.width: 1
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: themeLoader.item.shadowColor
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
                            GradientStop { position: 0.0; color: themeLoader.item.logoGradient0 }
                            GradientStop { position: 1.0; color: themeLoader.item.logoGradient1 }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "PM"
                            font.pixelSize: 24
                            font.bold: true
                            color: themeLoader.item.textPrimary
                        }
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Project Manager"
                        font.pixelSize: 28
                        font.bold: true
                        color: themeLoader.item.textPrimary
                    }
                    
                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Sign in to continue"
                        font.pixelSize: 14
                        color: themeLoader.item.textSecondary
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
                    color: themeLoader.item.textOnContainer
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: themeLoader.item.containerOverlay
                    radius: 12
                    border.color: usernameField.activeFocus ? themeLoader.item.primary : themeLoader.item.fieldBorderDefault
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    TextField {
                        id: usernameField
                        anchors.fill: parent
                        anchors.margins: 2
                        placeholderText: "Enter your username"
                        placeholderTextColor: themeLoader.item.textMuted
                        color: themeLoader.item.textPrimary
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
                    color: themeLoader.item.textOnContainer
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    color: themeLoader.item.containerOverlay
                    radius: 12
                    border.color: passwordField.activeFocus ? themeLoader.item.primary : themeLoader.item.fieldBorderDefault
                    border.width: 2
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 2
                        placeholderText: "Enter your password"
                        placeholderTextColor: themeLoader.item.textMuted
                        color: themeLoader.item.textPrimary
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
                color: themeLoader.item.error
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
                        GradientStop { position: 0.0; color: loginButton.pressed ? themeLoader.item.primaryPressed0 : themeLoader.item.primary }
                        GradientStop { position: 1.0; color: loginButton.pressed ? themeLoader.item.primaryPressed1 : themeLoader.item.primaryAlt }
                    }
                    
                    Behavior on scale {
                        NumberAnimation { duration: 100 }
                    }
                    
                    scale: loginButton.pressed ? 0.98 : 1.0
                }
                
                onClicked: {
                    if (usernameField.text === "" || passwordField.text === "") {
                        statusMessage.text = "Please fill in all fields"
                        statusMessage.color = themeLoader.item.error
                        return
                    }
                    
                    statusMessage.text = "Authenticating..."
                    statusMessage.color = themeLoader.item.info
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
            statusMessage.color = themeLoader.item.success
            
            // Clear fields after successful login
            usernameField.text = ""
            passwordField.text = ""
            
            // Load home screen after successful login
        }
        
        function onLoginFailed(errorMessage) {
            statusMessage.text = errorMessage
            statusMessage.color = themeLoader.item.error
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
        
        function onLoginStatusChanged(status) {
            if (status.indexOf("Authenticating") !== -1) {
                statusMessage.text = status
                statusMessage.color = themeLoader.item.info
            }
        }
    }
}
