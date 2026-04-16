import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Effects

Rectangle {
    id: root
    Loader { id: themeLoader; source: "qrc:/Screens/Theme.qml"; asynchronous: false }
    color: themeLoader.item.rootBackground

    // Gradient background
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: themeLoader.item.backgroundGradient2 }
            GradientStop { position: 0.5; color: themeLoader.item.backgroundGradient1 }
            GradientStop { position: 1.0; color: themeLoader.item.backgroundGradient0 }
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
            color: themeLoader.item.containerOverlay
            radius: 16
            border.color: themeLoader.item.fieldBorderDefault
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
                        GradientStop { position: 0.0; color: themeLoader.item.primary }
                        GradientStop { position: 1.0; color: themeLoader.item.primaryAlt }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: loginManager.currentUser ? loginManager.currentUser.charAt(0).toUpperCase() : "U"
                        font.pixelSize: 22
                        font.bold: true
                        color: themeLoader.item.textPrimary
                    }
                }

                // Welcome text
                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "Welcome back!"
                        font.pixelSize: 14
                        color: themeLoader.item.textSecondary
                    }

                    Text {
                        text: loginManager.currentUser || "User"
                        font.pixelSize: 20
                        font.bold: true
                        color: themeLoader.item.textPrimary
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
                        color: themeLoader.item.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: parent.pressed ? "#dc2626" : (parent.hovered ? themeLoader.item.error : "#f87171")

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

        // Main action buttons section (simplified)
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
                    color: themeLoader.item.containerOverlay
                    radius: 20
                    border.color: createProjectArea.containsMouse ? themeLoader.item.primary : themeLoader.item.fieldBorderDefault
                    border.width: 2

                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowColor: "#40000000"; shadowBlur: 0.4; shadowVerticalOffset: 15 }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 24

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 100
                            Layout.preferredHeight: 100
                            radius: 50
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: themeLoader.item.primary }
                                GradientStop { position: 1.0; color: themeLoader.item.primaryAlt }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 56
                                font.bold: true
                                color: themeLoader.item.textPrimary
                            }

                            scale: createProjectArea.containsMouse ? 1.1 : 1.0
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }

                        Text { Layout.alignment: Qt.AlignHCenter; text: "Create Project"; font.pixelSize: 24; font.bold: true; color: themeLoader.item.textPrimary }
                        Text { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 240; text: "Start a new project from scratch"; font.pixelSize: 14; color: themeLoader.item.textSecondary; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
                    }

                    MouseArea {
                        id: createProjectArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: screenLoader.loadScreen("Screens/CreateProjectScreen.qml")
                    }
                }

                // Open Project button (simplified)
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 320
                    color: themeLoader.item.containerOverlay
                    radius: 20
                    border.color: openProjectArea.containsMouse ? "#10b981" : themeLoader.item.fieldBorderDefault
                    border.width: 2

                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowColor: "#40000000"; shadowBlur: 0.4; shadowVerticalOffset: 15 }

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
                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        }

                        Text { Layout.alignment: Qt.AlignHCenter; text: "Open Project"; font.pixelSize: 24; font.bold: true; color: themeLoader.item.textPrimary }
                        Text { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 240; text: "Continue working on existing projects"; font.pixelSize: 14; color: themeLoader.item.textSecondary; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
                    }

                    MouseArea { id: openProjectArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: screenLoader.loadScreen("Screens/ProjectListScreen.qml") }
                }

                // Settings button (simplified)
                Rectangle {
                    Layout.preferredWidth: 280
                    Layout.preferredHeight: 320
                    color: themeLoader.item.containerOverlay
                    radius: 20
                    border.color: settingsArea.containsMouse ? "#f59e0b" : themeLoader.item.fieldBorderDefault
                    border.width: 2

                    layer.enabled: true
                    layer.effect: MultiEffect { shadowEnabled: true; shadowColor: "#40000000"; shadowBlur: 0.4; shadowVerticalOffset: 15 }

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

                            Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                            Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                        }

                        Text { Layout.alignment: Qt.AlignHCenter; text: "Settings"; font.pixelSize: 24; font.bold: true; color: themeLoader.item.textPrimary }
                        Text { Layout.alignment: Qt.AlignHCenter; Layout.preferredWidth: 240; text: "Configure app preferences and options"; font.pixelSize: 14; color: themeLoader.item.textSecondary; horizontalAlignment: Text.AlignHCenter; wrapMode: Text.WordWrap }
                    }

                    MouseArea { id: settingsArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: screenLoader.loadScreen("Screens/SettingsScreen.qml") }
                }
            }
        }
    }
}
