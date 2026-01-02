from PySide6.QtCore import QObject, Slot, Signal, Property
from datetime import datetime
import json
import os


class ProjectManager(QObject):
    """
    Backend manager for handling project creation and management.
    Provides methods to create, update, and retrieve project information.
    """
    
    # Signals
    projectCreated = Signal(str, str)  # Emits project name and manager name
    projectCreationFailed = Signal(str)  # Emits error message
    projectStatusChanged = Signal(str)  # Emits status messages
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._projects = []
        self._projects_file = "projects.json"
        self._load_projects()
    
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
    
    @Slot(str, str)
    def createProject(self, project_name, manager_name):
        """
        Create a new project with the provided details.
        
        Args:
            project_name: The name of the project
            manager_name: The name of the project manager
        """
        self.projectStatusChanged.emit("Creating project...")
        
        # Validate input
        if not project_name or not project_name.strip():
            self.projectCreationFailed.emit("Project name is required")
            return
        
        if not manager_name or not manager_name.strip():
            self.projectCreationFailed.emit("Project manager name is required")
            return
        
        # Check if project already exists
        for project in self._projects:
            if project.get("name", "").lower() == project_name.strip().lower():
                self.projectCreationFailed.emit("A project with this name already exists")
                return
        
        # Create new project
        new_project = {
            "name": project_name.strip(),
            "manager": manager_name.strip(),
            "created_date": datetime.now().isoformat(),
            "status": "Active",
            "tasks": []
        }
        
        self._projects.append(new_project)
        self._save_projects()
        
        self.projectCreated.emit(project_name.strip(), manager_name.strip())
        self.projectStatusChanged.emit(f"Project '{project_name}' created successfully!")
    
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
