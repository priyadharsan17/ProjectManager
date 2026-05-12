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
        spacing: 30

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            color: themeLoader.item.containerOverlay
            radius: 16
            border.color: themeLoader.item.fieldBorderDefault
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
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
                        color: themeLoader.item.textPrimary
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        radius: 10
                        color: parent.pressed ? themeLoader.item.primaryPressed0
                             : parent.hovered ? themeLoader.item.primary
                             : Qt.rgba(0.24, 0.25, 0.47, 0.8)
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    onClicked: screenLoader.loadHomeScreen()

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
                    font.pixelSize: 28
                    font.bold: true
                    color: themeLoader.item.textPrimary
                }
            }
        }

        // Form area
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                width: 580
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 20
                height: formLayout.implicitHeight + 80
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
                }

                ColumnLayout {
                    id: formLayout
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 40
                    }
                    spacing: 28

                    // Icon + subtitle
                    ColumnLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            width: 72
                            height: 72
                            radius: 36
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: themeLoader.item.primary }
                                GradientStop { position: 1.0; color: themeLoader.item.primaryAlt }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "+"
                                font.pixelSize: 44
                                font.bold: true
                                color: themeLoader.item.textPrimary
                            }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Fill in the project details below"
                            font.pixelSize: 14
                            color: themeLoader.item.textSecondary
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
                            color: themeLoader.item.textOnContainer
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 48
                            color: themeLoader.item.containerOverlay
                            radius: 12
                            border.color: projectNameField.activeFocus ? themeLoader.item.primary : themeLoader.item.fieldBorderDefault
                            border.width: 2
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            TextField {
                                id: projectNameField
                                anchors.fill: parent
                                anchors.margins: 2
                                placeholderText: "Enter project name"
                                placeholderTextColor: themeLoader.item.textMuted
                                color: themeLoader.item.textPrimary
                                font.pixelSize: 15
                                leftPadding: 16
                                background: Rectangle { color: "transparent" }
                                Keys.onReturnPressed: projectDetailsField.forceActiveFocus()
                            }
                        }
                    }

                    // Project Details field
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Project Details"
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: themeLoader.item.textOnContainer
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            color: themeLoader.item.containerOverlay
                            radius: 12
                            border.color: projectDetailsField.activeFocus ? themeLoader.item.primary : themeLoader.item.fieldBorderDefault
                            border.width: 2
                            Behavior on border.color { ColorAnimation { duration: 200 } }

                            ScrollView {
                                anchors.fill: parent
                                anchors.margins: 2
                                clip: true

                                TextArea {
                                    id: projectDetailsField
                                    placeholderText: "Enter project description or notes…"
                                    placeholderTextColor: themeLoader.item.textMuted
                                    color: themeLoader.item.textPrimary
                                    font.pixelSize: 15
                                    leftPadding: 16
                                    topPadding: 12
                                    wrapMode: TextArea.Wrap
                                    background: Rectangle { color: "transparent" }
                                }
                            }
                        }
                    }

                    // Status message
                    Text {
                        id: statusMessage
                        Layout.fillWidth: true
                        text: ""
                        font.pixelSize: 13
                        color: themeLoader.item.error
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        visible: text !== ""
                    }

                    // Create button
                    Button {
                        id: createButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 52

                        contentItem: Text {
                            text: "Create Project"
                            font.pixelSize: 16
                            font.bold: true
                            color: themeLoader.item.textPrimary
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        background: Rectangle {
                            radius: 12
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: createButton.pressed ? themeLoader.item.primaryPressed0 : themeLoader.item.primary }
                                GradientStop { position: 1.0; color: createButton.pressed ? themeLoader.item.primaryPressed1 : themeLoader.item.primaryAlt }
                            }
                            scale: createButton.pressed ? 0.98 : 1.0
                            Behavior on scale { NumberAnimation { duration: 100 } }
                        }

                        onClicked: {
                            if (projectNameField.text.trim() === "") {
                                statusMessage.color = themeLoader.item.error
                                statusMessage.text = "Please enter a project name."
                                return
                            }
                            statusMessage.color = themeLoader.item.info
                            statusMessage.text = "Creating project…"
                            projectManager.createProject(projectNameField.text, projectDetailsField.text)
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onPressed: function(mouse) { mouse.accepted = false }
                        }
                    }

                    Item { Layout.preferredHeight: 4 }
                }
            }
        }
    }

    // Connections to ProjectManager backend
    Connections {
        target: projectManager

        function onProjectCreated(projectName, folderPath) {
            statusMessage.color = themeLoader.item.success
            statusMessage.text = "Project '" + projectName + "' created successfully!"
            projectNameField.text = ""
            projectDetailsField.text = ""
            backTimer.start()
        }

        function onProjectCreationFailed(errorMessage) {
            statusMessage.color = themeLoader.item.error
            statusMessage.text = errorMessage
        }
    }

    // Navigate back after successful creation
    Timer {
        id: backTimer
        interval: 1800
        running: false
        repeat: false
        onTriggered: screenLoader.loadHomeScreen()
    }
}
