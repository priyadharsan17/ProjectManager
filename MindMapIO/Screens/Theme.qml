pragma Singleton
import QtQuick 2.15

QtObject {
    /* Backgrounds */
    property color rootBackground: "#050510"
    property color backgroundGradient0: "#0a0020"
    property color backgroundGradient1: "#060618"
    property color backgroundGradient2: "#02020e"

    /* Container */
    property color containerBackground: Qt.rgba(0.04, 0.04, 0.12, 0.92)
    property color containerBorder: Qt.rgba(0.2, 0.4, 0.9, 0.3)
    property color containerOverlay: Qt.rgba(0.07, 0.07, 0.2, 0.7)

    /* Primary / Brand */
    property color primary: "#00d4ff"
    property color primaryAlt: "#7b2fff"
    property color primaryGlow: "#0088aa"
    property color accent: "#ff2d78"
    property color accentAlt: "#ff6b35"

    /* Text */
    property color textPrimary: "#e0f4ff"
    property color textSecondary: "#6aa3c8"
    property color textMuted: "#3a607a"

    /* Node level colors */
    property color nodeRoot: "#00d4ff"
    property color nodeLevel1: "#7b2fff"
    property color nodeLevel2: "#ff2d78"
    property color nodeLevel3: "#10e898"
    property color nodeLevel4: "#ffb800"
    property color nodeLevel5: "#ff6b35"

    /* Canvas */
    property color canvasBg: "#04040f"
    property color gridLine: Qt.rgba(0.1, 0.3, 0.6, 0.18)
    property color edgeLine: Qt.rgba(0.0, 0.83, 1.0, 0.5)
    property color edgeGlow: Qt.rgba(0.0, 0.83, 1.0, 0.15)

    /* Misc */
    property color shadowColor: "#80000020"
    property color error: "#ff2d78"
    property color success: "#10e898"
    property color fieldBorderDefault: containerBorder
}
