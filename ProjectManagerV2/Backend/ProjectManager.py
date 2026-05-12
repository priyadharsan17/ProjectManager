from PySide6.QtCore import QObject, Slot, Signal
from datetime import datetime
import json
import os

class ProjectManager(QObject):
    """
    Backend manager for handling project creation and management.
    """

    # Signals
    projectCreated = Signal(str, str)       # project_name, folder_path
    projectCreationFailed = Signal(str)     # error_message
    projectStatusChanged = Signal(str)      # status_message

    def __init__(self, parent=None):
        super().__init__(parent)
        self._projects_file = os.path.join(os.getcwd(), "projects.json")
        self._workspace_dir = self._resolve_workspace_dir()
        self._projects = self._load_projects()

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _resolve_workspace_dir(self) -> str:
        """Return workspace directory, creating it if necessary."""
        workspace = os.path.join(os.getcwd(), "Workspace")
        os.makedirs(workspace, exist_ok=True)
        return workspace

    def _load_projects(self) -> list:
        if os.path.exists(self._projects_file):
            try:
                with open(self._projects_file, "r", encoding="utf-8") as f:
                    return json.load(f)
            except Exception as e:
                print(f"ProjectManager: failed to load projects — {e}")
        return []

    def _save_projects(self):
        try:
            with open(self._projects_file, "w", encoding="utf-8") as f:
                json.dump(self._projects, f, indent=4)
        except Exception as e:
            print(f"ProjectManager: failed to save projects — {e}")

    # ------------------------------------------------------------------
    # QML-exposed slots
    # ------------------------------------------------------------------

    @Slot(str, str)
    def createProject(self, project_name: str, project_details: str):
        """
        Create a new project.

        Args:
            project_name:    Display name for the project.
            project_details: Free-text description / notes for the project.
        """
        name = project_name.strip()
        details = project_details.strip()

        if not name:
            self.projectCreationFailed.emit("Project name is required.")
            return

        # Duplicate check (case-insensitive)
        for p in self._projects:
            if p.get("name", "").lower() == name.lower():
                self.projectCreationFailed.emit("A project with this name already exists.")
                return

        # Build folder path inside workspace
        safe_name = "".join(c if c.isalnum() or c in (" ", "_", "-") else "_" for c in name).strip()
        folder_path = os.path.join(self._workspace_dir, safe_name)

        try:
            os.makedirs(folder_path, exist_ok=True)
            os.makedirs(os.path.join(folder_path, "documents"), exist_ok=True)
            os.makedirs(os.path.join(folder_path, "resources"), exist_ok=True)
            os.makedirs(os.path.join(folder_path, "tasks"), exist_ok=True)

            project_info = {
                "name": name,
                "details": details,
                "created_date": datetime.now().isoformat(),
                "status": "Active",
                "folder_path": folder_path,
            }

            with open(os.path.join(folder_path, "project_info.json"), "w", encoding="utf-8") as f:
                json.dump(project_info, f, indent=4)

        except Exception as e:
            self.projectCreationFailed.emit(f"Failed to create project folder: {e}")
            return

        entry = {
            "name": name,
            "details": details,
            "created_date": datetime.now().isoformat(),
            "status": "Active",
            "folder_path": folder_path,
        }
        
        self._projects.append(entry)
        self._save_projects()

        self.projectCreated.emit(name, folder_path)
        self.projectStatusChanged.emit(f"Project '{name}' created successfully!")

    @Slot(result=str)
    def getWorkspaceDirectory(self) -> str:
        """Return the workspace directory path."""
        return self._workspace_dir

    @Slot(result=str)
    def getProjectList(self) -> str:
        """Return all projects as a JSON string."""
        return json.dumps(self._projects)

    @Slot(result=int)
    def getProjectCount(self) -> int:
        """Return the number of projects."""
        return len(self._projects)

    @Slot(str, result=str)
    def getProject(self, project_name: str) -> str:
        """Return a single project's data as a JSON string."""
        for p in self._projects:
            if p.get("name", "").lower() == project_name.lower():
                return json.dumps(p)
        return "{}"
