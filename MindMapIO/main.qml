import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    id: window
    visible: true
    width: 1280
    height: 800
    minimumWidth: 900
    minimumHeight: 600
    title: "MindMap IO"
    color: "#04040f"

    // ── Global navigation function called by child screens ─────────────────
    function navigate(screenName) {
        screenLoader.source = ""
        screenLoader.source = "Screens/" + screenName + ".qml"
    }

    Loader {
        id: screenLoader
        anchors.fill: parent
        source: "Screens/HomeScreen.qml"
        asynchronous: false
        onStatusChanged: {
            if (status === Loader.Error)
                console.log("Loader error:", source)
        }
    }
}
