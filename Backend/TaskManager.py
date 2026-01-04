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
        """Load tasks for a specific project from separate JSON files."""
        self._current_project_path = project_folder_path
        tasks_dir = os.path.join(project_folder_path, "tasks")
        
        # Ensure tasks directory exists
        os.makedirs(tasks_dir, exist_ok=True)
        
        self._tasks = []
        
        # Load from separate files: epics.json, features.json, pbis.json, tasks.json
        task_files = {
            "Epic": "epics.json",
            "Feature": "features.json",
            "PBI": "pbis.json",
            "Task": "tasks.json"
        }
        
        for task_type, filename in task_files.items():
            file_path = os.path.join(tasks_dir, filename)
            if os.path.exists(file_path):
                try:
                    with open(file_path, 'r') as f:
                        tasks_of_type = json.load(f)
                        # Convert simplified format to full task objects
                        for task_data in tasks_of_type:
                            # Find if task already exists (avoid duplicates)
                            existing = next((t for t in self._tasks if t.get("id") == task_data.get("ID")), None)
                            if not existing:
                                full_task = {
                                    "id": task_data.get("ID", ""),
                                    "type": task_type,
                                    "name": task_data.get("Name", ""),
                                    "description": task_data.get("Description", ""),
                                    "parent_id": task_data.get("Parent", ""),
                                    "status": task_data.get("Status", "ToDo"),
                                    "created_date": task_data.get("CreatedDate", ""),
                                    "estimated_days": task_data.get("EstimatedDays", 0),
                                    "start_date": task_data.get("StartDate", ""),
                                    "end_date": task_data.get("EndDate", ""),
                                    "progress": task_data.get("Progress", 0),
                                    "children": []
                                }
                                self._tasks.append(full_task)
                except Exception as e:
                    print(f"Error loading {filename}: {e}")
        
        # Build children relationships
        for task in self._tasks:
            task_id = task.get("id")
            for other_task in self._tasks:
                if other_task.get("parent_id") == task_id:
                    if task_id not in task.get("children", []):
                        if "children" not in task:
                            task["children"] = []
                        task["children"].append(other_task.get("id"))
        
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
        """Save tasks to separate JSON files by type."""
        if not self._current_project_path:
            return False
        
        tasks_dir = os.path.join(self._current_project_path, "tasks")
        os.makedirs(tasks_dir, exist_ok=True)
        
        # Group tasks by type
        task_files = {
            "Epic": "epics.json",
            "Feature": "features.json",
            "PBI": "pbis.json",
            "Task": "tasks.json"
        }
        
        try:
            for task_type, filename in task_files.items():
                file_path = os.path.join(tasks_dir, filename)
                
                # Filter tasks of this type and convert to simplified format
                tasks_of_type = []
                for task in self._tasks:
                    if task.get("type") == task_type:
                        simplified_task = {
                            "ID": task.get("id", ""),
                            "Name": task.get("name", ""),
                            "Description": task.get("description", ""),
                            "Parent": task.get("parent_id", ""),
                            "Status": task.get("status", "ToDo"),
                            "CreatedDate": task.get("created_date", ""),
                            "EstimatedDays": task.get("estimated_days", 0),
                            "StartDate": task.get("start_date", ""),
                            "EndDate": task.get("end_date", ""),
                            "Progress": task.get("progress", 0)
                        }
                        tasks_of_type.append(simplified_task)
                
                # Save to file
                with open(file_path, 'w') as f:
                    json.dump(tasks_of_type, f, indent=4)
            
            return True
        except Exception as e:
            print(f"Error saving tasks: {e}")
            return False
    
    @Slot(str, str, str, str, str, str, str)
    def createTask(self, task_type, task_name, description, parent_id, estimated_days="0", start_date="", end_date=""):
        """
        Create a new task.
        
        Args:
            task_type: Epic, Feature, PBI, or Task
            task_name: Name of the task
            description: Task description
            parent_id: ID of parent task (empty for Epic)
            estimated_days: Estimated work days for the task
            start_date: Start date (YYYY-MM-DD format)
            end_date: End date (YYYY-MM-DD format)
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
            "estimated_days": int(estimated_days) if estimated_days else 0,
            "start_date": start_date if start_date else "",
            "end_date": end_date if end_date else "",
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
    
    @Slot(str)
    def deleteTask(self, task_id):
        """Delete a task and all its children recursively."""
        # Find the task to delete
        task_to_delete = None
        for task in self._tasks:
            if task.get("id") == task_id:
                task_to_delete = task
                break
        
        if not task_to_delete:
            return
        
        # Collect all descendant IDs recursively
        def get_all_descendants(tid):
            descendants = [tid]
            for task in self._tasks:
                if task.get("parent_id") == tid:
                    descendants.extend(get_all_descendants(task.get("id")))
            return descendants
        
        ids_to_delete = get_all_descendants(task_id)
        
        # Remove all tasks with these IDs
        self._tasks = [task for task in self._tasks if task.get("id") not in ids_to_delete]
        
        # Update parent's children list if this task had a parent
        if task_to_delete.get("parent_id"):
            for task in self._tasks:
                if task.get("id") == task_to_delete.get("parent_id"):
                    if "children" in task and task_id in task["children"]:
                        task["children"].remove(task_id)
                    break
        
        # Save and emit signal
        self._save_tasks()
        self._build_hierarchy()
        self.taskDeleted.emit(task_id)
