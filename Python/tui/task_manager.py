"""
Simple Task Management Feature
Provides task creation, tracking, and completion functionality
"""

from dataclasses import dataclass, field
from typing import List, Dict
from datetime import datetime
from enum import Enum


class Priority(Enum):
    """Task priority levels"""
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    CRITICAL = 4


@dataclass
class TaskItem:
    """Single task item"""
    id: str
    title: str
    description: str
    priority: Priority = Priority.MEDIUM
    completed: bool = False
    created_at: str = field(default_factory=lambda: datetime.now().strftime("%Y-%m-%d %H:%M"))
    
    def display(self) -> str:
        """Display task in readable format"""
        status = "✅" if self.completed else "⬜"
        priority_emoji = {
            Priority.LOW: "🟢",
            Priority.MEDIUM: "🟡",
            Priority.HIGH: "🔴",
            Priority.CRITICAL: "🔴🔴"
        }
        return f"{status} [{priority_emoji[self.priority]}] {self.title} (ID: {self.id})"


class TaskManager:
    """Manage tasks for the team"""
    
    def __init__(self):
        self.tasks: Dict[str, TaskItem] = {}
        self.task_counter = 0
    
    def create_task(self, title: str, description: str, 
                   priority: Priority = Priority.MEDIUM) -> str:
        """Create a new task and return task ID"""
        self.task_counter += 1
        task_id = f"TSK-{self.task_counter:03d}"
        
        task = TaskItem(
            id=task_id,
            title=title,
            description=description,
            priority=priority
        )
        self.tasks[task_id] = task
        return task_id
    
    def complete_task(self, task_id: str) -> bool:
        """Mark task as completed"""
        if task_id in self.tasks:
            self.tasks[task_id].completed = True
            return True
        return False
    
    def get_task(self, task_id: str) -> TaskItem:
        """Get a specific task"""
        return self.tasks.get(task_id)
    
    def list_all_tasks(self) -> str:
        """List all tasks"""
        if not self.tasks:
            return "📋 No tasks yet"
        
        active = [t for t in self.tasks.values() if not t.completed]
        completed = [t for t in self.tasks.values() if t.completed]
        
        result = "📋 ACTIVE TASKS:\n"
        for task in sorted(active, key=lambda x: x.priority.value, reverse=True):
            result += "  " + task.display() + "\n"
        
        if completed:
            result += "\n✅ COMPLETED TASKS:\n"
            for task in completed:
                result += "  " + task.display() + "\n"
        
        return result
    
    def get_high_priority_tasks(self) -> str:
        """Get only high priority tasks"""
        high = [t for t in self.tasks.values() 
                if t.priority in [Priority.HIGH, Priority.CRITICAL] 
                and not t.completed]
        
        if not high:
            return "✅ No high priority tasks!"
        
        result = "🔴 HIGH PRIORITY TASKS:\n"
        for task in high:
            result += "  " + task.display() + "\n"
        return result
    
    def get_stats(self) -> str:
        """Get task statistics"""
        total = len(self.tasks)
        completed = sum(1 for t in self.tasks.values() if t.completed)
        pending = total - completed
        
        if total == 0:
            return "📊 No tasks to track"
        
        percentage = (completed / total) * 100
        
        return (
            f"📊 TASK STATISTICS:\n"
            f"  Total Tasks: {total}\n"
            f"  Completed: {completed}\n"
            f"  Pending: {pending}\n"
            f"  Progress: {percentage:.1f}%"
        )


# Pre-populated example tasks for demo
def get_example_tasks() -> TaskManager:
    """Create example task manager with sample data"""
    tm = TaskManager()
    
    tm.create_task(
        "Implement authentication",
        "Add user login/signup functionality",
        Priority.CRITICAL
    )
    tm.create_task(
        "Write unit tests",
        "Test all core modules",
        Priority.HIGH
    )
    tm.create_task(
        "Create API documentation",
        "Document all endpoints",
        Priority.MEDIUM
    )
    tm.create_task(
        "Setup CI/CD pipeline",
        "Configure GitHub Actions",
        Priority.HIGH
    )
    tm.create_task(
        "Update README",
        "Add installation and usage instructions",
        Priority.LOW
    )
    
    # Mark one task as completed
    task_id = list(tm.tasks.keys())[0]
    tm.complete_task(task_id)
    
    return tm


if __name__ == "__main__":
    tm = get_example_tasks()
    print(tm.list_all_tasks())
    print("\n")
    print(tm.get_stats())
