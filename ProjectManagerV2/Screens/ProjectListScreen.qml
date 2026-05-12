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
                    text: "Open Project"
                    font.pixelSize: 28
                    font.bold: true
                    color: themeLoader.item.textPrimary
                }
            }
        }

        // Content (empty)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
