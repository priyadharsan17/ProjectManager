from PySide6.QtCore import QObject, Slot, Signal, Property
import json
import os


class SettingsManager(QObject):
    """
    Backend manager for handling application settings.
    Manages workspace directory configuration and other app settings.
    """
    
    # Signals
    settingsSaved = Signal()
    settingsSaveFailed = Signal(str)
    workspaceDirectoryChanged = Signal(str)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._settings_file = "settings.json"
        self._workspace_directory = ""
        self._load_settings()
    
    def _load_settings(self):
        """Load settings from file."""
        if os.path.exists(self._settings_file):
            try:
                with open(self._settings_file, 'r') as f:
                    settings = json.load(f)
                    self._workspace_directory = settings.get("workspace_directory", "")
            except Exception as e:
                print(f"Error loading settings: {e}")
        
        # Set default workspace if not configured
        if not self._workspace_directory:
            self._workspace_directory = os.path.join(os.getcwd(), "Workspace")
            if not os.path.exists(self._workspace_directory):
                os.makedirs(self._workspace_directory)
    
    def _save_settings(self):
        """Save settings to file."""
        try:
            settings = {
                "workspace_directory": self._workspace_directory
            }
            with open(self._settings_file, 'w') as f:
                json.dump(settings, f, indent=4)
            return True
        except Exception as e:
            print(f"Error saving settings: {e}")
            return False
    
    @Slot(str)
    def setWorkspaceDirectory(self, directory_path):
        """
        Set the workspace directory path.
        
        Args:
            directory_path: The path to the workspace directory
        """
        if not directory_path or not directory_path.strip():
            self.settingsSaveFailed.emit("Workspace directory path is required")
            return
        
        directory_path = directory_path.strip()
        
        # Create directory if it doesn't exist
        try:
            if not os.path.exists(directory_path):
                os.makedirs(directory_path)
        except Exception as e:
            self.settingsSaveFailed.emit(f"Failed to create directory: {str(e)}")
            return
        
        # Update and save
        self._workspace_directory = directory_path
        
        if self._save_settings():
            self.workspaceDirectoryChanged.emit(directory_path)
            self.settingsSaved.emit()
        else:
            self.settingsSaveFailed.emit("Failed to save settings")
    
    @Slot(result=str)
    def getWorkspaceDirectory(self):
        """Get the current workspace directory."""
        return self._workspace_directory
    
    @Property(str, notify=workspaceDirectoryChanged)
    def workspaceDirectory(self):
        """Property to get the current workspace directory."""
        return self._workspace_directory
