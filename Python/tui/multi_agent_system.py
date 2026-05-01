"""
Multi-Agent System Framework
Provides a flexible agent architecture for team-based task management and collaboration
"""

from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from dataclasses import dataclass
from enum import Enum
from datetime import datetime


# ============= ENUMS =============
class AgentRole(Enum):
    """Predefined agent roles"""
    TEAMLEAD = "Team Lead"
    DEVELOPER = "Developer"
    TESTER = "Tester"
    REVIEWER = "Reviewer"
    DESIGNER = "Designer"
    DEVOPS = "DevOps"
    MANAGER = "Manager"
    ANALYST = "Analyst"


class TaskStatus(Enum):
    """Task status states"""
    PENDING = "Pending"
    IN_PROGRESS = "In Progress"
    COMPLETED = "Completed"
    BLOCKED = "Blocked"
    FAILED = "Failed"


# ============= DATA CLASSES =============
@dataclass
class Task:
    """Represents a task to be executed"""
    id: str
    title: str
    description: str
    assigned_to: Optional[str] = None
    status: TaskStatus = TaskStatus.PENDING
    priority: int = 1  # 1=low, 5=high
    created_at: str = None
    completed_at: Optional[str] = None
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now().isoformat()
    
    def __str__(self) -> str:
        return f"[{self.status.value}] {self.title} (Priority: {self.priority}/5)"


@dataclass
class Message:
    """Represents communication between agents"""
    sender: str
    recipient: str
    content: str
    timestamp: str = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()
    
    def __str__(self) -> str:
        return f"{self.sender} → {self.recipient}: {self.content}"


# ============= BASE AGENT CLASS =============
class Agent(ABC):
    """Abstract base class for all agents"""
    
    def __init__(self, name: str, role: AgentRole, skills: List[str] = None):
        self.name = name
        self.role = role
        self.skills = skills or []
        self.tasks: List[Task] = []
        self.completed_tasks: List[Task] = []
        self.inbox: List[Message] = []
    
    @abstractmethod
    def act(self) -> str:
        """Define agent behavior - implement in subclasses"""
        pass
    
    def receive_message(self, message: Message) -> None:
        """Receive a message from another agent"""
        self.inbox.append(message)
    
    def send_message(self, recipient: str, content: str) -> Message:
        """Create and log a message to send"""
        message = Message(sender=self.name, recipient=recipient, content=content)
        return message
    
    def assign_task(self, task: Task) -> bool:
        """Assign a task to this agent"""
        task.assigned_to = self.name
        task.status = TaskStatus.IN_PROGRESS
        self.tasks.append(task)
        return True
    
    def complete_task(self, task_id: str) -> bool:
        """Mark a task as completed"""
        for task in self.tasks:
            if task.id == task_id:
                task.status = TaskStatus.COMPLETED
                task.completed_at = datetime.now().isoformat()
                self.completed_tasks.append(task)
                self.tasks.remove(task)
                return True
        return False
    
    def get_status(self) -> str:
        """Get agent status"""
        return (
            f"👤 {self.name} ({self.role.value})\n"
            f"   Skills: {', '.join(self.skills) if self.skills else 'None'}\n"
            f"   Active Tasks: {len(self.tasks)}\n"
            f"   Completed: {len(self.completed_tasks)}"
        )
    
    def __str__(self) -> str:
        return f"{self.name} ({self.role.value})"


# ============= CONCRETE AGENT IMPLEMENTATIONS =============
class TeamLead(Agent):
    """Team Lead - coordinates and oversees projects"""
    
    def __init__(self, name: str = "Alice"):
        super().__init__(
            name=name,
            role=AgentRole.TEAMLEAD,
            skills=["Planning", "Coordination", "Reporting", "Decision Making"]
        )
    
    def act(self) -> str:
        return (
            f"📋 {self.name} ({self.role.value}): "
            f"Reviewing project status and coordinating team efforts..."
        )


class Developer(Agent):
    """Developer - writes code and implements features"""
    
    def __init__(self, name: str = "Bob"):
        super().__init__(
            name=name,
            role=AgentRole.DEVELOPER,
            skills=["Python", "JavaScript", "Problem Solving", "Code Design"]
        )
    
    def act(self) -> str:
        return (
            f"💻 {self.name} ({self.role.value}): "
            f"Implementing features and writing clean code..."
        )


class Tester(Agent):
    """Tester - tests functionality and reports issues"""
    
    def __init__(self, name: str = "Charlie"):
        super().__init__(
            name=name,
            role=AgentRole.TESTER,
            skills=["Test Planning", "Bug Tracking", "QA", "Test Automation"]
        )
    
    def act(self) -> str:
        return (
            f"🧪 {self.name} ({self.role.value}): "
            f"Running test cases and ensuring quality standards..."
        )


class Reviewer(Agent):
    """Reviewer - reviews code quality and standards"""
    
    def __init__(self, name: str = "Diana"):
        super().__init__(
            name=name,
            role=AgentRole.REVIEWER,
            skills=["Code Review", "Architecture", "Best Practices", "Documentation"]
        )
    
    def act(self) -> str:
        return (
            f"👁️ {self.name} ({self.role.value}): "
            f"Reviewing code for quality, security, and best practices..."
        )


class Designer(Agent):
    """Designer - designs UI/UX and system architecture"""
    
    def __init__(self, name: str = "Eve"):
        super().__init__(
            name=name,
            role=AgentRole.DESIGNER,
            skills=["UI/UX Design", "Prototyping", "User Research", "System Design"]
        )
    
    def act(self) -> str:
        return (
            f"🎨 {self.name} ({self.role.value}): "
            f"Designing intuitive interfaces and system architecture..."
        )


class DevOps(Agent):
    """DevOps - handles deployment, infrastructure, and CI/CD"""
    
    def __init__(self, name: str = "Frank"):
        super().__init__(
            name=name,
            role=AgentRole.DEVOPS,
            skills=["Docker", "Kubernetes", "CI/CD", "Infrastructure", "Monitoring"]
        )
    
    def act(self) -> str:
        return (
            f"⚙️ {self.name} ({self.role.value}): "
            f"Managing infrastructure and deployment pipelines..."
        )


class Manager(Agent):
    """Manager - manages resources and schedules"""
    
    def __init__(self, name: str = "Grace"):
        super().__init__(
            name=name,
            role=AgentRole.MANAGER,
            skills=["Resource Planning", "Scheduling", "Budget Management", "Reporting"]
        )
    
    def act(self) -> str:
        return (
            f"📊 {self.name} ({self.role.value}): "
            f"Managing resources, timelines, and project metrics..."
        )


class Analyst(Agent):
    """Analyst - analyzes data and provides insights"""
    
    def __init__(self, name: str = "Henry"):
        super().__init__(
            name=name,
            role=AgentRole.ANALYST,
            skills=["Data Analysis", "Reporting", "Metrics", "Business Intelligence"]
        )
    
    def act(self) -> str:
        return (
            f"📈 {self.name} ({self.role.value}): "
            f"Analyzing data and providing insights for decision making..."
        )


# ============= AGENT TEAM MANAGER =============
class AgentTeam:
    """Manages multiple agents and coordinates their work"""
    
    def __init__(self, name: str = "Default Team"):
        self.name = name
        self.agents: Dict[str, Agent] = {}
        self.tasks: List[Task] = []
        self.messages: List[Message] = []
        self.created_at = datetime.now().isoformat()
    
    def add_agent(self, agent: Agent) -> bool:
        """Add an agent to the team"""
        if agent.name not in self.agents:
            self.agents[agent.name] = agent
            return True
        return False
    
    def remove_agent(self, agent_name: str) -> bool:
        """Remove an agent from the team"""
        if agent_name in self.agents:
            del self.agents[agent_name]
            return True
        return False
    
    def get_agent(self, agent_name: str) -> Optional[Agent]:
        """Get an agent by name"""
        return self.agents.get(agent_name)
    
    def get_agents_by_role(self, role: AgentRole) -> List[Agent]:
        """Get all agents with a specific role"""
        return [agent for agent in self.agents.values() if agent.role == role]
    
    def create_task(self, task_id: str, title: str, description: str, 
                   priority: int = 1) -> Task:
        """Create a new task"""
        task = Task(
            id=task_id,
            title=title,
            description=description,
            priority=priority
        )
        self.tasks.append(task)
        return task
    
    def assign_task(self, task_id: str, agent_name: str) -> bool:
        """Assign a task to an agent"""
        task = next((t for t in self.tasks if t.id == task_id), None)
        agent = self.get_agent(agent_name)
        
        if task and agent:
            return agent.assign_task(task)
        return False
    
    def send_message(self, sender_name: str, recipient_name: str, 
                    content: str) -> Optional[Message]:
        """Send a message between agents"""
        sender = self.get_agent(sender_name)
        recipient = self.get_agent(recipient_name)
        
        if sender and recipient:
            message = sender.send_message(recipient_name, content)
            recipient.receive_message(message)
            self.messages.append(message)
            return message
        return None
    
    def get_team_status(self) -> str:
        """Get status of all agents in the team"""
        if not self.agents:
            return "❌ No agents in the team"
        
        status = f"🤖 TEAM: {self.name}\n"
        status += "=" * 50 + "\n"
        for agent in self.agents.values():
            status += agent.get_status() + "\n\n"
        
        status += f"Total Tasks: {len(self.tasks)}\n"
        status += f"Total Messages: {len(self.messages)}"
        return status
    
    def get_team_actions(self) -> str:
        """Get all agents' actions"""
        if not self.agents:
            return "❌ No agents in the team"
        
        actions = f"🤖 TEAM ACTIONS: {self.name}\n"
        actions += "=" * 50 + "\n"
        for agent in self.agents.values():
            actions += agent.act() + "\n"
        return actions
    
    def __str__(self) -> str:
        return f"Team: {self.name} ({len(self.agents)} agents)"


# ============= EXAMPLE USAGE =============
def example_usage():
    """Demonstrate the multi-agent system"""
    
    # Create a team
    team = AgentTeam(name="Engineering Team")
    
    # Add agents
    team.add_agent(TeamLead("Alice"))
    team.add_agent(Developer("Bob"))
    team.add_agent(Developer("Charlie"))
    team.add_agent(Tester("Diana"))
    team.add_agent(Reviewer("Eve"))
    team.add_agent(DevOps("Frank"))
    
    # Create tasks
    task1 = team.create_task(
        "T001",
        "Implement login system",
        "Create user authentication module",
        priority=5
    )
    task2 = team.create_task(
        "T002",
        "Write unit tests",
        "Test all authentication functions",
        priority=4
    )
    task3 = team.create_task(
        "T003",
        "Review code quality",
        "Perform code review on login module",
        priority=4
    )
    
    # Assign tasks
    team.assign_task("T001", "Bob")
    team.assign_task("T002", "Diana")
    team.assign_task("T003", "Eve")
    
    # Send messages
    team.send_message("Alice", "Bob", "Please start implementing the login system ASAP")
    team.send_message("Bob", "Diana", "Login feature is ready for testing")
    team.send_message("Diana", "Alice", "Found 3 edge case bugs in login flow")
    
    # Print status
    print(team.get_team_status())
    print("\n")
    print(team.get_team_actions())


if __name__ == "__main__":
    example_usage()
