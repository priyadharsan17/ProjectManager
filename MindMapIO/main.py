import sys
import os
from pathlib import Path

from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

from Backend.MindMapManager import MindMapManager


def main():
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"

    app = QGuiApplication(sys.argv)
    app.setApplicationName("MindMapIO")
    app.setOrganizationName("MindMapIO")

    engine = QQmlApplicationEngine()

    mind_map_manager = MindMapManager()
    engine.rootContext().setContextProperty("mindMapManager", mind_map_manager)

    qml_file = Path(__file__).parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print("Failed to load QML.")
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
