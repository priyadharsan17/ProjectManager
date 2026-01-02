from PySide6.QtCore import QObject, Slot, Signal, Property
import json
import os
from datetime import datetime


class TaskManager(QObject):
    """
    Backend manager for handling task hierarchy and definitions.
    Manages Epic -> Features -> PBIs -> Tasks hierarchy.
    """
    
    # Signals
    taskCreated = Signal(str, str, str)  # task_type, task_name, parent_id
    taskUpdated = Signal(str)  # task_id
    taskDeleted = Signal(str)  # task_id
    tasksLoaded = Signal()
    currentProjectChanged = Signal(str)
    
    def __init__(self, parent=None):
        super().__init__(parent)
        self._current_project_path = ""
        self._tasks = []
        self._task_hierarchy = {
            "Epic": [],
            "Feature": [],
            "PBI": [],
            "Task": []
        }
    
    @Slot(str)
    def loadProjectTasks(self, project_folder_path):
        """Load tasks for a specific project."""
        self._current_project_path = project_folder_path
        tasks_file = os.path.join(project_folder_path, "tasks", "tasks.json")
        
        if os.path.exists(tasks_file):
            try:
                with open(tasks_file, 'r') as f:
                    self._tasks = json.load(f)
            except Exception as e:
                print(f"Error loading tasks: {e}")
                self._tasks = []
        else:
            self._tasks = []
            # Ensure tasks directory exists
            os.makedirs(os.path.join(project_folder_path, "tasks"), exist_ok=True)
        
        self._build_hierarchy()
        self.currentProjectChanged.emit(project_folder_path)
        self.tasksLoaded.emit()
    
    def _build_hierarchy(self):
        """Build task hierarchy structure."""
        self._task_hierarchy = {
            "Epic": [],
            "Feature": [],
            "PBI": [],
            "Task": []
        }
        
        for task in self._tasks:
            task_type = task.get("type", "Task")
            if task_type in self._task_hierarchy:
                self._task_hierarchy[task_type].append(task)
    
    def _save_tasks(self):
        """Save tasks to file."""
        if not self._current_project_path:
            return False
        
        tasks_file = os.path.join(self._current_project_path, "tasks", "tasks.json")
        try:
            with open(tasks_file, 'w') as f:
                json.dump(self._tasks, f, indent=4)
            return True
        except Exception as e:
            print(f"Error saving tasks: {e}")
            return False
    
    @Slot(str, str, str, str)
    def createTask(self, task_type, task_name, description, parent_id):
        """
        Create a new task.
        
        Args:
            task_type: Epic, Feature, PBI, or Task
            task_name: Name of the task
            description: Task description
            parent_id: ID of parent task (empty for Epic)
        """
        if not task_name or not task_name.strip():
            return
        
        # Generate unique ID
        task_id = f"{task_type}_{len(self._tasks) + 1}_{datetime.now().timestamp()}"
        
        new_task = {
            "id": task_id,
            "type": task_type,
            "name": task_name.strip(),
            "description": description.strip() if description else "",
            "parent_id": parent_id if parent_id else "",
            "status": "Not Started",
            "created_date": datetime.now().isoformat(),
            "start_date": "",
            "end_date": "",
            "progress": 0,
            "children": []
        }
        
        self._tasks.append(new_task)
        
        # Update parent's children list
        if parent_id:
            for task in self._tasks:
                if task.get("id") == parent_id:
                    if "children" not in task:
                        task["children"] = []
                    task["children"].append(task_id)
                    break
        
        self._save_tasks()
        self._build_hierarchy()
        self.taskCreated.emit(task_type, task_name, parent_id)
    
    @Slot(str, result=str)
    def getTasksByType(self, task_type):
        """Get all tasks of a specific type as JSON."""
        if task_type in self._task_hierarchy:
            return json.dumps(self._task_hierarchy[task_type])
        return "[]"
    
    @Slot(result=str)
    def getAllTasks(self):
        """Get all tasks as JSON."""
        return json.dumps(self._tasks)
    
    @Slot(str, result=str)
    def getTask(self, task_id):
        """Get a specific task by ID."""
        for task in self._tasks:
            if task.get("id") == task_id:
                return json.dumps(task)
        return "{}"
    
    @Slot(str, result=str)
    def getChildTasks(self, parent_id):
        """Get child tasks of a parent task."""
        children = []
        for task in self._tasks:
            if task.get("parent_id") == parent_id:
                children.append(task)
        return json.dumps(children)
    
    @Slot(str, str)
    def updateTaskStatus(self, task_id, status):
        """Update task status."""
        for task in self._tasks:
            if task.get("id") == task_id:
                task["status"] = status
                self._save_tasks()
                self.taskUpdated.emit(task_id)
                break
    
    @Slot(str, int)
    def updateTaskProgress(self, task_id, progress):
        """Update task progress."""
        for task in self._tasks:
            if task.get("id") == task_id:
                task["progress"] = progress
                self._save_tasks()
                self.taskUpdated.emit(task_id)
                break
