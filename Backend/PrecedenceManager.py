from PySide6.QtCore import QObject, Slot
import json
import os

class PrecedenceManager(QObject):
    def __init__(self):
        super().__init__()
        self.project_folder = None
        self.precedence_data = {
            "Epic": {},
            "Feature": {},
            "PBI": {},
            "Task": {}
        }
    
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
        """Set predecessor for a specific task"""
        if task_type not in self.precedence_data:
            self.precedence_data[task_type] = {}
        
        self.precedence_data[task_type][task_id] = predecessor_id
        self._save_precedence(task_type)
    
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
