from PySide6.QtCore import QObject, Slot, Signal, Property, QFile
from pathlib import Path


class ScreenLoader(QObject):
    """
    Backend manager for handling screen navigation and transitions.
    Provides methods to switch between different screens in the application.
    """
    
    # Signals
    screenChanged = Signal(str)  # Emits the new screen path
    
    def __init__(self, parent=None):
        super().__init__(parent)
        # store qrc-style paths for consistency with resource loading
        self._current_screen = "qrc:/Screens/LoginScreen.qml"
        self._previous_screen = ""
    
    @Slot(str)
    def loadScreen(self, screen_path):
        """
        Load a new screen.
        
        Args:
            screen_path: Relative path to the QML screen file
        """
        # normalize to qrc path if a relative path is provided
        if not screen_path.startswith("qrc:/"):
            normalized = "qrc:/" + screen_path.lstrip("/")
        else:
            normalized = screen_path

        # check existence: for qrc paths convert to resource path 
        # (":/...") and use QFile.exists; for non-qrc fall back to filesystem
        def _exists(qrc_path: str) -> bool:
            if qrc_path.startswith("qrc:/"):
                res_path = ":" + qrc_path[4:]
                try:
                    return QFile.exists(res_path)
                except Exception:
                    return False
            # fallback: strip leading slash
            fs_path = qrc_path
            if fs_path.startswith("/"):
                fs_path = fs_path[1:]
            return Path(fs_path).exists()

        if not _exists(normalized):
            print(f"ScreenLoader: requested screen does not exist: {normalized}")
            return

        if normalized != self._current_screen:
            self._previous_screen = self._current_screen
            self._current_screen = normalized
            self.screenChanged.emit(normalized)
    
    @Slot()
    def loadHomeScreen(self):
        """Load the home screen after successful login."""
        self.loadScreen("Screens/HomeScreen.qml")
    
    @Slot()
    def loadLoginScreen(self):
        """Load the login screen (e.g., after logout)."""
        self.loadScreen("Screens/LoginScreen.qml")
    
    @Slot()
    def goBack(self):
        """Navigate back to the previous screen."""
        if self._previous_screen:
            temp = self._current_screen
            self._current_screen = self._previous_screen
            self._previous_screen = temp
            self.screenChanged.emit(self._current_screen)
    
    @Property(str, notify=screenChanged)
    def currentScreen(self):
        """Property to get the current screen path."""
        return self._current_screen
    
    @Property(str)
    def previousScreen(self):
        """Property to get the previous screen path."""
        return self._previous_screen
