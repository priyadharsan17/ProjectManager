import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Dialog {
    id: calendarDialog
    modal: true
    width: 380
    height: 450
    
    property int currentMonth: new Date().getMonth()
    property int currentYear: new Date().getFullYear()
    property string selectedDate: ""
    
    signal dateSelected(string date)
    
    function getDaysInMonth(month, year) {
        return new Date(year, month + 1, 0).getDate()
    }
    
    function getFirstDayOfMonth(month, year) {
        return new Date(year, month, 1).getDay()
    }
    
    background: Rectangle {
        color: "#1f2937"
        radius: 12
        border.color: "#374151"
        border.width: 1
    }
    
    header: Rectangle {
        width: parent.width
        height: 60
        color: "#1f2937"
        radius: 12
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10
            
            Button {
                text: "◄"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                onClicked: {
                    if (calendarDialog.currentMonth === 0) {
                        calendarDialog.currentMonth = 11
                        calendarDialog.currentYear--
                    } else {
                        calendarDialog.currentMonth--
                    }
                    calendarGrid.model = calendarDialog.getDaysInMonth(calendarDialog.currentMonth, calendarDialog.currentYear) + calendarDialog.getFirstDayOfMonth(calendarDialog.currentMonth, calendarDialog.currentYear)
                }
                background: Rectangle {
                    color: parent.hovered ? "#4b5563" : "#374151"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            
            Text {
                Layout.fillWidth: true
                text: Qt.formatDate(new Date(calendarDialog.currentYear, calendarDialog.currentMonth), "MMMM yyyy")
                font.pixelSize: 16
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
            
            Button {
                text: "►"
                Layout.preferredWidth: 40
                Layout.preferredHeight: 40
                onClicked: {
                    if (calendarDialog.currentMonth === 11) {
                        calendarDialog.currentMonth = 0
                        calendarDialog.currentYear++
                    } else {
                        calendarDialog.currentMonth++
                    }
                    calendarGrid.model = calendarDialog.getDaysInMonth(calendarDialog.currentMonth, calendarDialog.currentYear) + calendarDialog.getFirstDayOfMonth(calendarDialog.currentMonth, calendarDialog.currentYear)
                }
                background: Rectangle {
                    color: parent.hovered ? "#4b5563" : "#374151"
                    radius: 6
                }
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.pixelSize: 16
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
    
    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 5
            
            // Weekday headers
            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 5
                columnSpacing: 5
                
                Repeater {
                    model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    Text {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 30
                        text: modelData
                        font.pixelSize: 12
                        font.bold: true
                        color: "#9ca3af"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                }
            }
            
            // Calendar grid
            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 5
                columnSpacing: 5
                
                Repeater {
                    id: calendarGrid
                    model: calendarDialog.getDaysInMonth(calendarDialog.currentMonth, calendarDialog.currentYear) + calendarDialog.getFirstDayOfMonth(calendarDialog.currentMonth, calendarDialog.currentYear)
                    
                    Rectangle {
                        Layout.preferredWidth: 45
                        Layout.preferredHeight: 45
                        radius: 22.5
                        
                        property int dayNumber: index - calendarDialog.getFirstDayOfMonth(calendarDialog.currentMonth, calendarDialog.currentYear) + 1
                        property bool isValidDay: dayNumber > 0 && dayNumber <= calendarDialog.getDaysInMonth(calendarDialog.currentMonth, calendarDialog.currentYear)
                        property bool isToday: {
                            var today = new Date()
                            return isValidDay && 
                                   dayNumber === today.getDate() && 
                                   calendarDialog.currentMonth === today.getMonth() && 
                                   calendarDialog.currentYear === today.getFullYear()
                        }
                        
                        color: {
                            if (!isValidDay) return "transparent"
                            if (isToday) return "#6366f1"
                            if (dayMouseArea.containsMouse) return "#4b5563"
                            return "transparent"
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: parent.isValidDay ? parent.dayNumber : ""
                            font.pixelSize: 14
                            color: parent.isValidDay ? "white" : "transparent"
                        }
                        
                        MouseArea {
                            id: dayMouseArea
                            anchors.fill: parent
                            enabled: parent.isValidDay
                            hoverEnabled: true
                            cursorShape: parent.isValidDay ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                if (parent.isValidDay) {
                                    var selected = new Date(calendarDialog.currentYear, calendarDialog.currentMonth, parent.dayNumber)
                                    calendarDialog.selectedDate = Qt.formatDate(selected, "yyyy-MM-dd")
                                    calendarDialog.dateSelected(calendarDialog.selectedDate)
                                    calendarDialog.close()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
