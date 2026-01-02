import sys
import os
from pathlib import Path
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtCore import QUrl

# Import the LoginManager backend
from Backend.LoginManager import LoginManager


def main():
    """
    Main entry point for the Project Manager application.
    Sets up the PySide6 QML application with the LoginManager backend.
    """
    # Set QML style to Basic to allow full customization
    os.environ["QT_QUICK_CONTROLS_STYLE"] = "Basic"
    
    # Create the application
    app = QGuiApplication(sys.argv)
    app.setApplicationName("Project Manager")
    app.setOrganizationName("ProjectManager")
    
    # Create QML engine
    engine = QQmlApplicationEngine()
    
    # Create LoginManager instance
    login_manager = LoginManager()
    
    # Expose LoginManager to QML
    engine.rootContext().setContextProperty("loginManager", login_manager)
    
    # Load the main QML file
    qml_file = Path(__file__).parent / "main.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))
    
    # Check if the QML file loaded successfully
    if not engine.rootObjects():
        sys.exit(-1)
    
    # Execute the application
    sys.exit(app.exec())


if __name__ == "__main__":
    main()
