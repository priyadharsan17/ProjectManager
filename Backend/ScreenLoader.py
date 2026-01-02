from PySide6.QtCore import QObject, Slot, Signal, Property


class ScreenLoader(QObject):
    """
    Backend manager for handling screen navigation and transitions.
    Provides methods to switch between different screens in the application.
    """
    
    # Signals
    screenChanged = Signal(str)  # Emits the new screen path
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._current_screen = "Screens/LoginScreen.qml"
        self._previous_screen = ""
    
    @Slot(str)
    def loadScreen(self, screen_path):
        """
        Load a new screen.
        
        Args:
            screen_path: Relative path to the QML screen file
        """
        if screen_path != self._current_screen:
            self._previous_screen = self._current_screen
            self._current_screen = screen_path
            self.screenChanged.emit(screen_path)
    
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
    
    @Property(str)
    def currentScreen(self):
        """Property to get the current screen path."""
        return self._current_screen
    
    @Property(str)
    def previousScreen(self):
        """Property to get the previous screen path."""
        return self._previous_screen
