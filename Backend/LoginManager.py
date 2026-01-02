from PySide6.QtCore import QObject, Slot, Signal, Property


class LoginManager(QObject):
    """
    Backend manager for handling user authentication.
    Provides slots for login operations and signals for status updates.
    """
    
    # Signals
    loginSuccess = Signal(str)  # Emits username on successful login
    loginFailed = Signal(str)   # Emits error message on failed login
    loginStatusChanged = Signal(str)  # Emits status messages
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._is_logged_in = False
        self._current_user = ""
        
    @Slot(str, str)
    def login(self, username, password):
        """
        Attempt to log in with the provided credentials.
        
        Args:
            username: The username entered by the user
            password: The password entered by the user
        """
        self.loginStatusChanged.emit("Authenticating...")
        
        # Validate input
        if not username or not password:
            self.loginFailed.emit("Username and password are required")
            return
        
        # Simple validation (in a real app, this would check against a database)
        if len(password) < 6:
            self.loginFailed.emit("Password must be at least 6 characters")
            return
        
        # Demo credentials (replace with actual authentication in production)
        if username == "admin" and password == "admin123":
            self._is_logged_in = True
            self._current_user = username
            self.loginSuccess.emit(username)
            self.loginStatusChanged.emit(f"Welcome, {username}!")
        elif username == "demo" and password == "demo123":
            self._is_logged_in = True
            self._current_user = username
            self.loginSuccess.emit(username)
            self.loginStatusChanged.emit(f"Welcome, {username}!")
        else:
            self.loginFailed.emit("Invalid username or password")
    
    @Slot()
    def logout(self):
        """Log out the current user."""
        self._is_logged_in = False
        self._current_user = ""
        self.loginStatusChanged.emit("Logged out successfully")
    
    @Property(bool)
    def isLoggedIn(self):
        """Property to check if a user is currently logged in."""
        return self._is_logged_in
    
    @Property(str)
    def currentUser(self):
        """Property to get the current logged-in username."""
        return self._current_user
