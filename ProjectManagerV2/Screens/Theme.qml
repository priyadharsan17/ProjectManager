pragma Singleton
import QtQuick 2.15

QtObject {
	/* Backgrounds */
	property color rootBackground: "#0a0a0a"
	property color backgroundGradient0: "#1a0a2e"
	property color backgroundGradient1: "#16213e"
	property color backgroundGradient2: "#0f0e17"

	/* Container */
	property color containerBackground: Qt.rgba(0.08, 0.08, 0.12, 0.95)
	property color containerBorder: Qt.rgba(0.3, 0.3, 0.4, 0.3)
	property color containerOverlay: Qt.rgba(0.15, 0.15, 0.2, 0.6)

	/* Shadows */
	property color shadowColor: "#80000000"

	/* Primary / Brand */
	property color primary: "#6366f1"
	property color primaryAlt: "#8b5cf6"
	property color primaryPressed0: "#5558e3"
	property color primaryPressed1: "#7c3aed"

	/* Text */
	property color textPrimary: "white"
	property color textSecondary: "#94a3b8"
	property color textMuted: "#64748b"
	property color textOnContainer: "#cbd5e1"

	/* Status colors */
	property color error: "#ef4444"
	property color success: "#22c55e"
	property color info: "#3b82f6"

	/* Misc */
	property color logoGradient0: primary
	property color logoGradient1: primaryAlt
	property color fieldBorderDefault: containerBorder
}

