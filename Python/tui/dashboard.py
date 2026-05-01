from textual.app import App, ComposeResult
from textual.screen import Screen
from textual.widgets import Header, Footer, Button, Static, Input
from textual.containers import Vertical, Horizontal
from task_manager import TaskManager, Priority, get_example_tasks
from standalone_multi_agent import (
    MultiAgentTeam, ArchitectAgent, DeveloperAgent, 
    TesterAgent, ReviewerAgent, DevOpsAgent
)
from typing import Optional

# ============= LOCAL AGENT TEAM MANAGER =============
class LocalAgentTeam:
    """Manages local agents from multi-agent system"""
    def __init__(self):
        self.agents = {
            'architect': ArchitectAgent("Alex"),
            'developer': DeveloperAgent("Bob"),
            'tester': TesterAgent("Charlie"),
            'reviewer': ReviewerAgent("Diana"),
            'devops': DevOpsAgent("Frank")
        }
    
    def get_agent(self, role: str):
        return self.agents.get(role.lower())
    
    def all_agents_status(self) -> str:
        status = "🤖 MULTI-AGENT TEAM STATUS:\n" + "="*50 + "\n"
        for role, agent in self.agents.items():
            status += agent.act() + "\n"
        return status

# ----------- Screen for main menu -----------
class MenuDashboard(App):
    CSS_PATH = "dashboard.css"
    
    def __init__(self):
        super().__init__()
        self.team = LocalAgentTeam()  # Use multi-agent system
        self.task_manager = get_example_tasks()  # Initialize task manager
        self.multi_agent_team: Optional[MultiAgentTeam] = None

    def compose(self) -> ComposeResult:
        yield Header(show_clock=True)
        yield Static("🤖 Multi-Agent Team Dashboard", id="title")

        with Vertical(id="menu"):
            yield Button("🚀 Create New App (Multi-Agent)", id="create_app")
            yield Button("🏗️  Architect", id="architect")
            yield Button("💻 Developer", id="developer")
            yield Button("🧪 Tester", id="tester")
            yield Button("👁️ Reviewer", id="reviewer")
            yield Button("⚙️  DevOps", id="devops")
            yield Button("📋 View All Tasks", id="tasks")
            yield Button("🔴 High Priority Tasks", id="high_priority")
            yield Button("📊 Task Statistics", id="stats")
            yield Button("📊 All Agents Status", id="all_status")
            yield Button("💬 Workflow Log", id="workflow_log")
            yield Button("Exit", id="exit")

        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        button_id = event.button.id
        
        if button_id == "exit":
            self.exit()
        elif button_id == "create_app":
            self.push_screen(CreateAppScreen(self))
        elif button_id == "tasks":
            content = self.task_manager.list_all_tasks()
            self.push_screen(AgentScreen(content, "All Tasks"))
        elif button_id == "high_priority":
            content = self.task_manager.get_high_priority_tasks()
            self.push_screen(AgentScreen(content, "High Priority Tasks"))
        elif button_id == "stats":
            content = self.task_manager.get_stats()
            self.push_screen(AgentScreen(content, "Task Statistics"))
        elif button_id == "all_status":
            if self.multi_agent_team:
                content = self.multi_agent_team.get_team_status()
            else:
                content = self.team.all_agents_status()
            self.push_screen(AgentScreen(content, "Team Status"))
        elif button_id == "workflow_log":
            if self.multi_agent_team:
                content = self.multi_agent_team.get_workflow_log()
                content += "\n\n" + self.multi_agent_team.get_communication_history()
            else:
                content = "No workflow executed yet. Create an app first!"
            self.push_screen(AgentScreen(content, "Workflow Log"))
        else:
            # Show individual agent
            agent = self.team.get_agent(button_id)
            if agent:
                self.push_screen(AgentScreen(agent.act(), agent.role.value))


# ----------- App Creation Screen -----------
class CreateAppScreen(Screen):
    def __init__(self, app_instance):
        super().__init__()
        self.app_instance = app_instance
        self.app_name = ""
        self.app_description = ""
    
    def compose(self) -> ComposeResult:
        yield Header()
        yield Static("🚀 Create New Application (Multi-Agent Execution)", id="agent_title")
        yield Static("Creating: E-Commerce Platform\nDescription: Full-stack e-commerce solution", id="agent_content")
        yield Button("Execute Workflow", id="execute")
        yield Button("Back", id="back")
        yield Footer()
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "execute":
            self.execute_multi_agent_workflow()
        elif event.button.id == "back":
            self.app.pop_screen()
    
    def execute_multi_agent_workflow(self) -> None:
        """Execute the multi-agent workflow"""
        # Create team
        team = MultiAgentTeam(team_name="Development Team")
        
        # Add agents
        team.add_agent(ArchitectAgent("Alex"))
        team.add_agent(DeveloperAgent("Bob"))
        team.add_agent(TesterAgent("Charlie"))
        team.add_agent(ReviewerAgent("Diana"))
        team.add_agent(DevOpsAgent("Frank"))
        
        # Create app request
        team.create_app_request(
            name="E-Commerce Platform",
            description="Full-stack e-commerce platform with payment processing",
            features=[
                "User authentication",
                "Product catalog",
                "Shopping cart",
                "Payment processing"
            ],
            tech_stack=["Python", "FastAPI", "PostgreSQL", "React", "Docker"]
        )
        
        # Execute workflow
        team.execute_workflow()
        
        # Store reference in main app
        self.app_instance.multi_agent_team = team
        
        # Show results
        results = team.get_summary()
        self.app.pop_screen()
        self.app.push_screen(AgentScreen(results + "\n\n✅ Workflow execution completed!\nCheck 'Workflow Log' for details.", "App Created Successfully"))


# ----------- Agent Display Screen -----------
class AgentScreen(Screen):
    def __init__(self, content: str, title: str):
        super().__init__()
        self.content = content
        self.screen_title = title

    def compose(self) -> ComposeResult:
        yield Header()
        yield Static(f"🤖 {self.screen_title}", id="agent_title")
        yield Static(self.content, id="agent_content")
        yield Button("Back", id="back")
        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "back":
            self.app.pop_screen()


# ----------- Run app -----------
if __name__ == "__main__":
    MenuDashboard().run()
