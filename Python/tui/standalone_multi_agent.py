"""
Standalone Multi-Agent Collaborative System
Request app creation -> Agents collaborate on design, development, testing, review
Can be integrated with existing codebases or run standalone
"""

from abc import ABC, abstractmethod
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, field
from enum import Enum
from datetime import datetime
from queue import Queue
import json


# ============= ENUMS =============
class TaskStatus(Enum):
    """Task status states"""
    PENDING = "Pending"
    IN_PROGRESS = "In Progress"
    COMPLETED = "Completed"
    BLOCKED = "Blocked"
    FAILED = "Failed"
    REVIEW = "Under Review"


class AgentRole(Enum):
    """Agent roles in the system"""
    ARCHITECT = "Architect"
    DEVELOPER = "Developer"
    TESTER = "Tester"
    REVIEWER = "Reviewer"
    DEVOPS = "DevOps"


# ============= DATA CLASSES =============
@dataclass
class WorkItem:
    """Unit of work for an agent"""
    id: str
    title: str
    description: str
    assigned_role: AgentRole
    status: TaskStatus = TaskStatus.PENDING
    assigned_to: Optional[str] = None
    output: str = ""
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    started_at: Optional[str] = None
    completed_at: Optional[str] = None
    dependencies: List[str] = field(default_factory=list)
    
    def __str__(self) -> str:
        return f"[{self.status.value}] {self.title} ({self.assigned_role.value})"


@dataclass
class AppRequest:
    """Request to create a new application"""
    id: str
    name: str
    description: str
    features: List[str]
    tech_stack: List[str]
    created_at: str = field(default_factory=lambda: datetime.now().isoformat())
    
    def __str__(self) -> str:
        return f"App: {self.name} - {self.description}"


class CommunicationQueue:
    """Inter-agent communication system"""
    
    def __init__(self):
        self.messages: List[Dict[str, Any]] = []
    
    def send_message(self, sender: str, recipient: str, 
                    content: str, message_type: str = "info") -> None:
        """Send message between agents"""
        message = {
            "sender": sender,
            "recipient": recipient,
            "content": content,
            "type": message_type,
            "timestamp": datetime.now().isoformat()
        }
        self.messages.append(message)
    
    def get_messages(self, recipient: str) -> List[Dict[str, Any]]:
        """Get messages for a specific agent"""
        return [m for m in self.messages if m["recipient"] == recipient]
    
    def clear_messages(self, recipient: str) -> None:
        """Clear read messages"""
        self.messages = [m for m in self.messages if m["recipient"] != recipient]
    
    def get_all_messages(self) -> List[Dict[str, Any]]:
        """Get all communication history"""
        return self.messages


# ============= BASE AGENT CLASS =============
class Agent(ABC):
    """Abstract base agent class"""
    
    def __init__(self, name: str, role: AgentRole):
        self.name = name
        self.role = role
        self.work_queue: List[WorkItem] = []
        self.completed_work: List[WorkItem] = []
        self.current_work: Optional[WorkItem] = None
        self.communication_queue: Optional[CommunicationQueue] = None
    
    def set_communication(self, comm_queue: CommunicationQueue) -> None:
        """Register communication queue"""
        self.communication_queue = comm_queue
    
    def receive_work(self, work_item: WorkItem) -> None:
        """Receive work to do"""
        work_item.assigned_to = self.name
        work_item.status = TaskStatus.PENDING
        self.work_queue.append(work_item)
    
    def start_work(self, work_id: str) -> bool:
        """Start working on a task"""
        for work in self.work_queue:
            if work.id == work_id:
                self.current_work = work
                work.status = TaskStatus.IN_PROGRESS
                work.started_at = datetime.now().isoformat()
                return True
        return False
    
    @abstractmethod
    def execute(self) -> str:
        """Execute work and return output"""
        pass
    
    def complete_work(self) -> bool:
        """Complete current work"""
        if self.current_work:
            self.current_work.status = TaskStatus.COMPLETED
            self.current_work.completed_at = datetime.now().isoformat()
            self.completed_work.append(self.current_work)
            self.work_queue.remove(self.current_work)
            self.current_work = None
            return True
        return False
    
    def send_message(self, recipient: str, content: str, msg_type: str = "info") -> None:
        """Send message to another agent"""
        if self.communication_queue:
            self.communication_queue.send_message(self.name, recipient, content, msg_type)
    
    def get_inbox(self) -> List[Dict[str, Any]]:
        """Get messages from other agents"""
        if self.communication_queue:
            return self.communication_queue.get_messages(self.name)
        return []
    
    def get_status(self) -> str:
        """Get agent status"""
        return (
            f"👤 {self.name} ({self.role.value})\n"
            f"   Pending: {len(self.work_queue)}\n"
            f"   In Progress: {'Yes' if self.current_work else 'No'}\n"
            f"   Completed: {len(self.completed_work)}"
        )
    
    def __str__(self) -> str:
        return f"{self.name} ({self.role.value})"


# ============= CONCRETE AGENT IMPLEMENTATIONS =============
class ArchitectAgent(Agent):
    """Designs system architecture and creates structure"""
    
    def __init__(self, name: str = "Alex"):
        super().__init__(name, AgentRole.ARCHITECT)
    
    def execute(self) -> str:
        if not self.current_work:
            return "No work assigned"
        
        output = f"""
🏗️ ARCHITECTURE DESIGN - {self.current_work.title}
{'='*60}
Project: {self.current_work.title}
Description: {self.current_work.description}

PROPOSED ARCHITECTURE:
├── Backend
│   ├── API Layer (REST/GraphQL)
│   ├── Business Logic
│   ├── Database Layer
│   └── Cache Layer
├── Frontend
│   ├── UI Components
│   ├── State Management
│   └── API Integration
├── Infrastructure
│   ├── Containerization (Docker)
│   ├── Orchestration (K8s)
│   └── CI/CD Pipeline
└── Testing
    ├── Unit Tests
    ├── Integration Tests
    └── E2E Tests

PROJECT STRUCTURE:
/app
├── backend/
│   ├── src/
│   ├── tests/
│   └── requirements.txt
├── frontend/
│   ├── src/
│   ├── tests/
│   └── package.json
├── infra/
│   ├── docker/
│   └── kubernetes/
└── docs/
    └── architecture.md

STATUS: ✅ Architecture designed and ready for development
Next: Assign to Developer team
        """
        
        self.current_work.output = output
        self.send_message("Developer-1", f"Architecture ready for {self.current_work.title}. Starting implementation.", "task")
        self.send_message("Developer-2", f"Architecture ready for {self.current_work.title}. Starting implementation.", "task")
        
        return output


class DeveloperAgent(Agent):
    """Implements features based on architecture"""
    
    def __init__(self, name: str = "Bob"):
        super().__init__(name, AgentRole.DEVELOPER)
    
    def execute(self) -> str:
        if not self.current_work:
            return "No work assigned"
        
        output = f"""
💻 DEVELOPMENT IMPLEMENTATION - {self.current_work.title}
{'='*60}
Task: {self.current_work.title}

CODE STRUCTURE CREATED:
✅ Initialize project with chosen tech stack
✅ Setup project dependencies
✅ Create module structure
✅ Implement core features
✅ Add error handling
✅ Add logging

SAMPLE CODE CREATED:
- API endpoints scaffolding
- Database models
- Service layer
- Utility functions
- Configuration management

DEVELOPMENT STATUS:
- Core functionality: 80% complete
- Error handling: 70% complete
- Logging: 60% complete

Next Steps:
1. Unit tests (Tester)
2. Code review (Reviewer)
3. Deployment (DevOps)

STATUS: ✅ Development checkpoint reached
        """
        
        self.current_work.output = output
        self.send_message("Tester-1", f"Code ready for testing: {self.current_work.title}", "task")
        
        return output


class TesterAgent(Agent):
    """Tests code quality and functionality"""
    
    def __init__(self, name: str = "Charlie"):
        super().__init__(name, AgentRole.TESTER)
    
    def execute(self) -> str:
        if not self.current_work:
            return "No work assigned"
        
        output = f"""
🧪 TESTING REPORT - {self.current_work.title}
{'='*60}
Test Suite Execution:

UNIT TESTS:
✅ API Endpoint Tests: 45/45 passed
✅ Model Tests: 32/32 passed
✅ Service Tests: 28/28 passed
✅ Utility Tests: 18/18 passed
Total: 123/123 passed (100%)

INTEGRATION TESTS:
✅ Database Integration: 12/12 passed
✅ API Integration: 15/15 passed
✅ Service Integration: 10/10 passed
Total: 37/37 passed (100%)

CODE COVERAGE:
Line Coverage: 95%
Branch Coverage: 88%
Function Coverage: 92%

PERFORMANCE TESTS:
✅ API Response Time: <200ms
✅ Database Queries: <100ms
✅ Memory Usage: Within limits

ISSUES FOUND: 2 minor, 0 critical
- Minor: Add validation for edge cases
- Minor: Optimize database queries

STATUS: ✅ Tests passed with recommendations
        """
        
        self.current_work.output = output
        self.current_work.status = TaskStatus.REVIEW
        self.send_message("Reviewer-1", f"Testing complete for {self.current_work.title}. Ready for review.", "task")
        
        return output


class ReviewerAgent(Agent):
    """Reviews code quality and best practices"""
    
    def __init__(self, name: str = "Diana"):
        super().__init__(name, AgentRole.REVIEWER)
    
    def execute(self) -> str:
        if not self.current_work:
            return "No work assigned"
        
        output = f"""
👁️ CODE REVIEW REPORT - {self.current_work.title}
{'='*60}
Review Checklist:

CODE QUALITY:
✅ Code style consistency
✅ Naming conventions
✅ Function complexity (all < 10)
✅ DRY principle adherence
✅ Error handling coverage

ARCHITECTURE:
✅ Follows design patterns
✅ Proper separation of concerns
✅ Scalability considerations
✅ Dependency management

SECURITY:
✅ Input validation
✅ Authentication checks
✅ Authorization controls
✅ Sensitive data handling
✅ SQL injection prevention

DOCUMENTATION:
✅ Code comments where needed
✅ API documentation
✅ README file
✅ Setup instructions

PERFORMANCE:
✅ No N+1 queries
✅ Proper indexing
✅ Cache usage
✅ Algorithm complexity

ISSUES FOUND: 0 blocking, 1 suggestion
- Suggestion: Extract common logic into utility function

APPROVAL STATUS: ✅ APPROVED FOR DEPLOYMENT
        """
        
        self.current_work.output = output
        self.send_message("DevOps-1", f"Code approved for deployment: {self.current_work.title}", "task")
        
        return output


class DevOpsAgent(Agent):
    """Handles deployment and infrastructure"""
    
    def __init__(self, name: str = "Frank"):
        super().__init__(name, AgentRole.DEVOPS)
    
    def execute(self) -> str:
        if not self.current_work:
            return "No work assigned"
        
        output = f"""
⚙️ DEPLOYMENT & INFRASTRUCTURE - {self.current_work.title}
{'='*60}
Deployment Plan:

INFRASTRUCTURE SETUP:
✅ Docker images created
✅ Docker Compose configured
✅ Kubernetes manifests prepared
✅ Environment configurations set

CI/CD PIPELINE:
✅ GitHub Actions workflow
✅ Automated testing on push
✅ Build optimization
✅ Artifact storage

DEPLOYMENT STEPS:
1. ✅ Code checkout
2. ✅ Dependencies installation
3. ✅ Tests execution
4. ✅ Docker image build
5. ✅ Push to registry
6. ✅ Kubernetes deployment
7. ✅ Health checks
8. ✅ Smoke tests

MONITORING & ALERTS:
✅ Prometheus metrics
✅ Grafana dashboards
✅ ELK stack logging
✅ Alert rules configured

ROLLBACK PLAN:
✅ Version control tags
✅ Database migration rollback
✅ Blue-green deployment ready

DEPLOYMENT STATUS: ✅ DEPLOYED TO PRODUCTION
Uptime: 99.9%
Response Time: <150ms avg
        """
        
        self.current_work.output = output
        
        return output


# ============= AGENT TEAM COORDINATOR =============
class MultiAgentTeam:
    """Coordinates multiple agents working on app creation"""
    
    def __init__(self, team_name: str = "Development Team"):
        self.team_name = team_name
        self.agents: Dict[str, Agent] = {}
        self.communication = CommunicationQueue()
        self.app_request: Optional[AppRequest] = None
        self.workflow_history: List[str] = []
        self.created_at = datetime.now().isoformat()
    
    def create_app_request(self, name: str, description: str, 
                          features: List[str], tech_stack: List[str]) -> AppRequest:
        """Create application request"""
        request_id = f"APP-{datetime.now().strftime('%Y%m%d%H%M%S')}"
        self.app_request = AppRequest(
            id=request_id,
            name=name,
            description=description,
            features=features,
            tech_stack=tech_stack
        )
        self.log_workflow(f"📱 App request created: {self.app_request.name}")
        return self.app_request
    
    def add_agent(self, agent: Agent) -> None:
        """Add agent to team"""
        agent.set_communication(self.communication)
        self.agents[agent.name] = agent
        self.log_workflow(f"✅ Agent added: {agent}")
    
    def assign_work(self, agent_name: str, work_item: WorkItem) -> bool:
        """Assign work to agent"""
        agent = self.agents.get(agent_name)
        if agent:
            agent.receive_work(work_item)
            self.log_workflow(f"📋 Work assigned to {agent_name}: {work_item.title}")
            return True
        return False
    
    def execute_workflow(self) -> Dict[str, str]:
        """Execute complete workflow for app creation"""
        if not self.app_request:
            return {"status": "error", "message": "No app request created"}
        
        results = {}
        
        # Step 1: Architecture
        self.log_workflow("🚀 Starting workflow execution...")
        self.log_workflow("Step 1: Architecture Design")
        
        architect = self.agents.get("Alex")
        if architect:
            work = WorkItem(
                id="WORK-001",
                title=f"Design architecture for {self.app_request.name}",
                description=f"Create system design for: {self.app_request.description}",
                assigned_role=AgentRole.ARCHITECT
            )
            architect.receive_work(work)
            architect.start_work("WORK-001")
            results["architecture"] = architect.execute()
            architect.complete_work()
        
        # Step 2: Development
        self.log_workflow("Step 2: Development")
        
        developers = [self.agents.get("Bob"), self.agents.get("Dev2")]
        for i, dev in enumerate([d for d in developers if d], 1):
            work = WorkItem(
                id=f"WORK-00{i+1}",
                title=f"Implement features - Part {i}",
                description=f"Develop features: {', '.join(self.app_request.features[:len(self.app_request.features)//2])}",
                assigned_role=AgentRole.DEVELOPER,
                dependencies=["WORK-001"]
            )
            dev.receive_work(work)
            dev.start_work(f"WORK-00{i+1}")
            results[f"development_{i}"] = dev.execute()
            dev.complete_work()
        
        # Step 3: Testing
        self.log_workflow("Step 3: Testing")
        
        tester = self.agents.get("Charlie")
        if tester:
            work = WorkItem(
                id="WORK-004",
                title="Run comprehensive tests",
                description="Execute unit, integration, and performance tests",
                assigned_role=AgentRole.TESTER,
                dependencies=["WORK-002", "WORK-003"]
            )
            tester.receive_work(work)
            tester.start_work("WORK-004")
            results["testing"] = tester.execute()
            tester.complete_work()
        
        # Step 4: Review
        self.log_workflow("Step 4: Code Review")
        
        reviewer = self.agents.get("Diana")
        if reviewer:
            work = WorkItem(
                id="WORK-005",
                title="Code review and quality assurance",
                description="Review code for quality, security, and best practices",
                assigned_role=AgentRole.REVIEWER,
                dependencies=["WORK-004"]
            )
            reviewer.receive_work(work)
            reviewer.start_work("WORK-005")
            results["review"] = reviewer.execute()
            reviewer.complete_work()
        
        # Step 5: Deployment
        self.log_workflow("Step 5: Deployment")
        
        devops = self.agents.get("Frank")
        if devops:
            work = WorkItem(
                id="WORK-006",
                title="Deploy to production",
                description="Setup infrastructure and deploy application",
                assigned_role=AgentRole.DEVOPS,
                dependencies=["WORK-005"]
            )
            devops.receive_work(work)
            devops.start_work("WORK-006")
            results["deployment"] = devops.execute()
            devops.complete_work()
        
        self.log_workflow("✅ Workflow execution completed successfully!")
        return results
    
    def log_workflow(self, message: str) -> None:
        """Log workflow events"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_entry = f"[{timestamp}] {message}"
        self.workflow_history.append(log_entry)
    
    def get_team_status(self) -> str:
        """Get status of all agents"""
        status = f"\n🤖 TEAM STATUS: {self.team_name}\n"
        status += "=" * 60 + "\n"
        
        for agent in self.agents.values():
            status += agent.get_status() + "\n\n"
        
        return status
    
    def get_workflow_log(self) -> str:
        """Get workflow execution log"""
        log = f"\n📋 WORKFLOW LOG: {self.team_name}\n"
        log += "=" * 60 + "\n"
        for entry in self.workflow_history:
            log += entry + "\n"
        return log
    
    def get_communication_history(self) -> str:
        """Get all inter-agent communication"""
        messages = self.communication.get_all_messages()
        comm = f"\n💬 COMMUNICATION HISTORY\n"
        comm += "=" * 60 + "\n"
        
        for msg in messages:
            timestamp = msg["timestamp"].split("T")[1][:8]
            comm += f"[{timestamp}] {msg['sender']} → {msg['recipient']}: {msg['content']}\n"
        
        return comm
    
    def get_summary(self) -> str:
        """Get complete project summary"""
        summary = f"""
╔════════════════════════════════════════════════════════════╗
║         MULTI-AGENT PROJECT EXECUTION SUMMARY             ║
╚════════════════════════════════════════════════════════════╝

📱 PROJECT: {self.app_request.name if self.app_request else 'N/A'}
📝 DESCRIPTION: {self.app_request.description if self.app_request else 'N/A'}
🛠️ TECH STACK: {', '.join(self.app_request.tech_stack) if self.app_request else 'N/A'}

👥 TEAM COMPOSITION:
"""
        for agent in self.agents.values():
            summary += f"  ✓ {agent.name} ({agent.role.value})\n"
        
        total_work = sum(len(a.completed_work) for a in self.agents.values())
        summary += f"\n✅ COMPLETED WORK ITEMS: {total_work}\n"
        summary += f"📊 TOTAL AGENTS: {len(self.agents)}\n"
        summary += f"⏱️ CREATED AT: {self.created_at}\n"
        
        return summary


# ============= EXAMPLE USAGE =============
def create_sample_app():
    """Create a sample application using multi-agent system"""
    
    # Initialize team
    team = MultiAgentTeam(team_name="E-Commerce Platform Team")
    
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
            "Payment processing",
            "Order management",
            "Admin dashboard"
        ],
        tech_stack=["Python", "FastAPI", "PostgreSQL", "React", "Docker", "Kubernetes"]
    )
    
    # Execute workflow
    results = team.execute_workflow()
    
    # Display results
    print(team.get_summary())
    print(team.get_team_status())
    print(team.get_workflow_log())
    print(team.get_communication_history())
    
    # Save detailed results
    for stage, output in results.items():
        print(f"\n{'='*60}")
        print(f"STAGE: {stage.upper()}")
        print(f"{'='*60}")
        print(output)
    
    return team


if __name__ == "__main__":
    team = create_sample_app()
