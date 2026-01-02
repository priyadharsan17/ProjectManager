from PySide6.QtCore import QObject, Slot, Signal, Property
from datetime import datetime
import json
import os
import shutil


class ProjectManager(QObject):
    """
    Backend manager for handling project creation and management.
    Provides methods to create, update, and retrieve project information.
    """
    
    # Signals
    projectCreated = Signal(str, str, str)  # Emits project name, manager name, and folder path
    projectCreationFailed = Signal(str)  # Emits error message
    projectStatusChanged = Signal(str)  # Emits status messages
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._projects = []
        self._projects_file = "projects.json"
        self._settings_file = "settings.json"
        self._workspace_dir = self._load_workspace_directory()
        self._load_projects()
    
    def _load_workspace_directory(self):
        """Load workspace directory from settings."""
        if os.path.exists(self._settings_file):
            try:
                with open(self._settings_file, 'r') as f:
                    settings = json.load(f)
                    workspace_dir = settings.get("workspace_directory", "")
                    if workspace_dir and os.path.exists(workspace_dir):
                        return workspace_dir
            except Exception as e:
                print(f"Error loading workspace directory: {e}")
        
        # Default to a "Workspace" folder in the current directory
        default_workspace = os.path.join(os.getcwd(), "Workspace")
        if not os.path.exists(default_workspace):
            os.makedirs(default_workspace)
        return default_workspace
    
    def _load_projects(self):
        """Load existing projects from file."""
        if os.path.exists(self._projects_file):
            try:
                with open(self._projects_file, 'r') as f:
                    self._projects = json.load(f)
            except Exception as e:
                print(f"Error loading projects: {e}")
                self._projects = []
    
    def _save_projects(self):
        """Save projects to file."""
        try:
            with open(self._projects_file, 'w') as f:
                json.dump(self._projects, f, indent=4)
        except Exception as e:
            print(f"Error saving projects: {e}")
    
    @Slot(str, str, str)
    def createProject(self, project_name, manager_name, project_folder):
        """
        Create a new project with the provided details.
        
        Args:
            project_name: The name of the project
            manager_name: The name of the project manager
            project_folder: The folder path where project files will be stored
        """
        self.projectStatusChanged.emit("Creating project...")
        
        # Validate input
        if not project_name or not project_name.strip():
            self.projectCreationFailed.emit("Project name is required")
            return
        
        if not manager_name or not manager_name.strip():
            self.projectCreationFailed.emit("Project manager name is required")
            return
        
        if not project_folder or not project_folder.strip():
            self.projectCreationFailed.emit("Project folder is required")
            return
        
        # Check if project already exists
        for project in self._projects:
            if project.get("name", "").lower() == project_name.strip().lower():
                self.projectCreationFailed.emit("A project with this name already exists")
                return
        
        # Create project folder structure
        try:
            project_folder_path = project_folder.strip()
            if not os.path.exists(project_folder_path):
                os.makedirs(project_folder_path)
            
            # Create project subfolders
            os.makedirs(os.path.join(project_folder_path, "documents"), exist_ok=True)
            os.makedirs(os.path.join(project_folder_path, "resources"), exist_ok=True)
            os.makedirs(os.path.join(project_folder_path, "tasks"), exist_ok=True)
            
            # Create project info file
            project_info = {
                "name": project_name.strip(),
                "manager": manager_name.strip(),
                "created_date": datetime.now().isoformat(),
                "status": "Active",
                "folder_path": project_folder_path,
                "tasks": []
            }
            
            project_info_file = os.path.join(project_folder_path, "project_info.json")
            with open(project_info_file, 'w') as f:
                json.dump(project_info, f, indent=4)
            
        except Exception as e:
            self.projectCreationFailed.emit(f"Failed to create project folder: {str(e)}")
            return
        
        # Create new project entry
        new_project = {
            "name": project_name.strip(),
            "manager": manager_name.strip(),
            "created_date": datetime.now().isoformat(),
            "status": "Active",
            "folder_path": project_folder_path,
            "tasks": []
        }
        
        self._projects.append(new_project)
        self._save_projects()
        
        self.projectCreated.emit(project_name.strip(), manager_name.strip(), project_folder_path)
        self.projectStatusChanged.emit(f"Project '{project_name}' created successfully!")
    
    @Slot(result=str)
    def getWorkspaceDirectory(self):
        """Get the current workspace directory."""
        return self._workspace_dir
    
    @Slot()
    def refreshWorkspaceDirectory(self):
        """Refresh workspace directory from settings."""
        self._workspace_dir = self._load_workspace_directory()
    
    @Slot(result=int)
    def getProjectCount(self):
        """Get the total number of projects."""
        return len(self._projects)
    
    @Slot(result=str)
    def getProjectList(self):
        """Get a JSON string of all projects."""
        return json.dumps(self._projects)
    
    @Slot(str, result=str)
    def getProject(self, project_name):
        """Get project details by name."""
        for project in self._projects:
            if project.get("name", "").lower() == project_name.lower():
                return json.dumps(project)
        return "{}"
