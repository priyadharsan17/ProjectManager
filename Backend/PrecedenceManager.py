from PySide6.QtCore import QObject, Slot, Signal
import json
import os
from datetime import datetime, timedelta

class PrecedenceManager(QObject):
    # Signal emitted when task dates are updated
    taskDatesUpdated = Signal(str, str, str, str)  # task_type, task_id, start_date, end_date
    
    def __init__(self):
        super().__init__()
        self.project_folder = None
        self.precedence_data = {
            "Epic": {},
            "Feature": {},
            "PBI": {},
            "Task": {}
        }
        self.task_manager = None
    
    @Slot(str)
    def loadProjectPrecedence(self, project_folder):
        """Load precedence data for a project"""
        self.project_folder = project_folder
        precedence_dir = os.path.join(project_folder, "PrecedenceDefinition")
        
        # Create directory if it doesn't exist
        if not os.path.exists(precedence_dir):
            os.makedirs(precedence_dir)
        
        # Load each task type's precedence data
        task_types = {
            "Epic": "epics.json",
            "Feature": "features.json",
            "PBI": "pbis.json",
            "Task": "tasks.json"
        }
        
        for task_type, filename in task_types.items():
            filepath = os.path.join(precedence_dir, filename)
            if os.path.exists(filepath):
                try:
                    with open(filepath, 'r') as f:
                        data = json.load(f)
                        # Convert list to dictionary for easier access
                        self.precedence_data[task_type] = {item['ID']: item.get('Predecessor', '') for item in data}
                except:
                    self.precedence_data[task_type] = {}
            else:
                self.precedence_data[task_type] = {}
    
    @Slot(str, str, result=str)
    def getPredecessor(self, task_type, task_id):
        """Get predecessor for a specific task"""
        return self.precedence_data.get(task_type, {}).get(task_id, "")
    
    @Slot(str, str, str)
    def setPredecessor(self, task_type, task_id, predecessor_id):
        """Set predecessor for a specific task and update dates automatically"""
        if task_type not in self.precedence_data:
            self.precedence_data[task_type] = {}
        
        self.precedence_data[task_type][task_id] = predecessor_id
        self._save_precedence(task_type)
        
        print(f"Setting predecessor for {task_id}: {predecessor_id}")
        
        # Update successor's dates based on predecessor
        if predecessor_id and predecessor_id.strip() and self.task_manager:
            self._update_successor_dates(task_type, task_id, predecessor_id)
        else:
            print(f"No predecessor or task manager for {task_id}")
    
    @Slot(str)
    def recalculateAllDates(self, task_type):
        """Recalculate dates for all tasks of a given type based on their predecessors"""
        if task_type not in self.precedence_data:
            return
        
        print(f"Recalculating dates for all {task_type} tasks")
        
        for task_id, predecessor_ref in self.precedence_data[task_type].items():
            if predecessor_ref and predecessor_ref.strip():
                self._update_successor_dates(task_type, task_id, predecessor_ref)
    
    def _save_precedence(self, task_type):
        """Save precedence data for a specific task type"""
        if not self.project_folder:
            return
        
        precedence_dir = os.path.join(self.project_folder, "PrecedenceDefinition")
        
        # Create directory if it doesn't exist
        if not os.path.exists(precedence_dir):
            os.makedirs(precedence_dir)
        
        # Map task type to filename
        filenames = {
            "Epic": "epics.json",
            "Feature": "features.json",
            "PBI": "pbis.json",
            "Task": "tasks.json"
        }
        
        filename = filenames.get(task_type)
        if not filename:
            return
        
        filepath = os.path.join(precedence_dir, filename)
        
        # Convert dictionary to list format
        data = [{"ID": task_id, "Predecessor": pred} for task_id, pred in self.precedence_data[task_type].items()]
        
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=4)
    
    def set_task_manager(self, task_manager):
        """Set reference to TaskManager for updating task dates"""
        self.task_manager = task_manager
    
    def _update_successor_dates(self, task_type, successor_id, predecessor_ref):
        """Update successor task dates based on predecessor's end date and successor's estimated days"""
        if not self.task_manager:
            print("No task manager available")
            return
        
        # Resolve predecessor reference (could be row number or task ID)
        predecessor = self._resolve_predecessor(task_type, predecessor_ref)
        successor = self._get_task_by_id(successor_id)
        
        if not predecessor:
            print(f"Predecessor not found for reference: {predecessor_ref}")
            return
            
        if not successor:
            print(f"Successor not found: {successor_id}")
            return
        
        # Get predecessor's end date
        pred_end_date = predecessor.get("end_date", "")
        if not pred_end_date:
            print(f"Predecessor has no end date: {predecessor.get('name', 'Unknown')}")
            return
        
        try:
            # Parse predecessor's end date
            pred_end = datetime.strptime(pred_end_date, "%Y-%m-%d")
            
            # Calculate successor's start date (next working day after predecessor ends)
            successor_start = self._get_next_working_day(pred_end)
            
            # Get successor's estimated days
            estimated_days = int(successor.get("estimated_days", 0))
            if estimated_days <= 0:
                print(f"Successor has no estimated days: {successor.get('name', 'Unknown')}")
                return
            
            # Calculate successor's end date (adding working days)
            successor_end = self._add_working_days(successor_start, estimated_days - 1)
            
            print(f"Updating dates for {successor.get('name')}: {successor_start.strftime('%Y-%m-%d')} to {successor_end.strftime('%Y-%m-%d')}")
            
            # Update successor task dates
            self._update_task_dates(successor_id, 
                                   successor_start.strftime("%Y-%m-%d"),
                                   successor_end.strftime("%Y-%m-%d"))
            
            # Emit signal for UI update
            self.taskDatesUpdated.emit(task_type, successor_id, 
                                      successor_start.strftime("%Y-%m-%d"),
                                      successor_end.strftime("%Y-%m-%d"))
            
        except Exception as e:
            print(f"Error updating successor dates: {e}")
    
    def _get_next_working_day(self, date):
        """Get the next working day (skip weekends)"""
        next_day = date + timedelta(days=1)
        
        # Skip weekends (Saturday = 5, Sunday = 6)
        while next_day.weekday() >= 5:
            next_day += timedelta(days=1)
        
        return next_day
    
    def _resolve_predecessor(self, task_type, predecessor_ref):
        """Resolve predecessor reference (could be row number or task ID)"""
        if not predecessor_ref:
            return None
        
        # First, try to get task by ID directly
        task = self._get_task_by_id(predecessor_ref)
        if task:
            return task
        
        # If not found, try to parse as row number and get task by index
        try:
            row_num = int(predecessor_ref)
            # Get all tasks of the same type, sorted by name
            tasks = self._get_tasks_by_type(task_type)
            
            if 0 <= row_num < len(tasks):
                return tasks[row_num]
        except ValueError:
            pass
        
        return None
    
    def _add_working_days(self, start_date, working_days):
        """Add working days to a date, skipping weekends"""
        current_date = start_date
        days_added = 0
        
        while days_added < working_days:
            current_date += timedelta(days=1)
            # Only count weekdays (Monday=0 to Friday=4)
            if current_date.weekday() < 5:
                days_added += 1
        
        return current_date
    
    def _get_task_by_id(self, task_id):
        """Get task from TaskManager by ID"""
        if not self.task_manager:
            return None
        
        tasks = self.task_manager._tasks
        if not tasks:
            return None
        
        for task in tasks:
            if task.get("id") == task_id:
                return task
        
        return None
    
    def _get_tasks_by_type(self, task_type):
        """Get all tasks of a specific type, sorted by name"""
        if not self.task_manager:
            return []
        
        tasks = self.task_manager._tasks
        if not tasks:
            return []
        
        # Filter by type and sort by name
        filtered_tasks = [task for task in tasks if task.get("type") == task_type]
        filtered_tasks.sort(key=lambda t: t.get("name", ""))
        
        return filtered_tasks
    
    def _update_task_dates(self, task_id, start_date, end_date):
        """Update task dates in TaskManager"""
        if not self.task_manager:
            return
        
        tasks = self.task_manager._tasks
        
        for task in tasks:
            if task.get("id") == task_id:
                task["start_date"] = start_date
                task["end_date"] = end_date
                break
        
        # Save the updated tasks
        self.task_manager._save_tasks()
    
    @Slot(str, str)
    def deletePrecedence(self, task_type, task_id):
        """Delete precedence entry for a task and clean up references to it"""
        if task_type not in self.precedence_data:
            return
        
        # Remove the task's own precedence entry
        if task_id in self.precedence_data[task_type]:
            del self.precedence_data[task_type][task_id]
        
        # Remove any references to this task as a predecessor
        for tid, pred in list(self.precedence_data[task_type].items()):
            if pred == task_id:
                self.precedence_data[task_type][tid] = ""
        
        # Save the updated precedence data
        self._save_precedence(task_type)
