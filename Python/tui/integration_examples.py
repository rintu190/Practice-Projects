"""
Integration Examples: How to use multi-agent system with existing codebases
"""

# ============= EXAMPLE 1: CLI Integration =============
"""
Create a file: agent_cli.py

Run with:
    python3 agent_cli.py create-app "MyApp" "My app description"
"""

import sys
from standalone_multi_agent import (
    MultiAgentTeam, ArchitectAgent, DeveloperAgent,
    TesterAgent, ReviewerAgent, DevOpsAgent
)


def cli_create_app(name: str, description: str, features: list = None, 
                   tech_stack: list = None):
    """CLI command to create an app using multi-agent system"""
    
    if features is None:
        features = ["Core functionality", "Testing", "Deployment"]
    if tech_stack is None:
        tech_stack = ["Python", "FastAPI", "PostgreSQL"]
    
    print(f"\n🚀 Starting Multi-Agent App Creation: {name}")
    print("=" * 60)
    
    # Create team
    team = MultiAgentTeam(team_name=f"{name} Team")
    
    # Add agents
    team.add_agent(ArchitectAgent("Architect-1"))
    team.add_agent(DeveloperAgent("Developer-1"))
    team.add_agent(DeveloperAgent("Developer-2"))
    team.add_agent(TesterAgent("Tester-1"))
    team.add_agent(ReviewerAgent("Reviewer-1"))
    team.add_agent(DevOpsAgent("DevOps-1"))
    
    # Create app request
    team.create_app_request(
        name=name,
        description=description,
        features=features,
        tech_stack=tech_stack
    )
    
    # Execute workflow
    results = team.execute_workflow()
    
    # Display results
    print(team.get_summary())
    print(team.get_team_status())
    print(team.get_workflow_log())
    
    return team


# ============= EXAMPLE 2: Web API Integration =============
"""
Create a file: agent_api.py

Run with:
    pip install flask
    python3 agent_api.py
    
Then call:
    curl -X POST http://localhost:5000/api/create-app \
         -H "Content-Type: application/json" \
         -d '{"name":"MyAPI","description":"REST API"}'
"""

try:
    from flask import Flask, request, jsonify
    
    app = Flask(__name__)
    
    @app.route('/api/create-app', methods=['POST'])
    def create_app_api():
        """API endpoint to create app via multi-agent system"""
        data = request.json
        
        team = MultiAgentTeam(team_name=f"{data.get('name', 'App')} Team")
        
        # Setup agents
        team.add_agent(ArchitectAgent())
        team.add_agent(DeveloperAgent())
        team.add_agent(TesterAgent())
        team.add_agent(ReviewerAgent())
        team.add_agent(DevOpsAgent())
        
        # Create app
        team.create_app_request(
            name=data.get('name', 'New App'),
            description=data.get('description', ''),
            features=data.get('features', []),
            tech_stack=data.get('tech_stack', [])
        )
        
        # Execute
        results = team.execute_workflow()
        
        return jsonify({
            'status': 'success',
            'summary': team.get_summary(),
            'workflow_log': team.get_workflow_log()
        })
    
    @app.route('/api/team-status', methods=['GET'])
    def team_status():
        """Get current team status"""
        # Note: In production, maintain team reference
        return jsonify({
            'status': 'ready',
            'agents': ['Architect', 'Developer', 'Tester', 'Reviewer', 'DevOps']
        })
    
except ImportError:
    pass


# ============= EXAMPLE 3: Script Integration =============
"""
Integrate into existing project structure
"""

def integrate_with_existing_project(project_path: str, app_config: dict):
    """
    Integrate multi-agent system with existing project
    
    Args:
        project_path: Path to existing project
        app_config: Configuration dictionary with app details
    """
    from pathlib import Path
    import json
    
    # Initialize team
    team = MultiAgentTeam(team_name=f"{app_config['name']} Enhancement Team")
    
    # Add agents
    team.add_agent(ArchitectAgent("Design Lead"))
    team.add_agent(DeveloperAgent("Senior Dev"))
    team.add_agent(DeveloperAgent("Junior Dev"))
    team.add_agent(TesterAgent("QA Lead"))
    team.add_agent(ReviewerAgent("Code Reviewer"))
    team.add_agent(DevOpsAgent("Infrastructure"))
    
    # Create request
    team.create_app_request(
        name=app_config['name'],
        description=app_config.get('description', ''),
        features=app_config.get('features', []),
        tech_stack=app_config.get('tech_stack', [])
    )
    
    # Execute workflow
    results = team.execute_workflow()
    
    # Save results to project
    project_dir = Path(project_path)
    results_dir = project_dir / ".agent-workflow"
    results_dir.mkdir(exist_ok=True)
    
    # Save workflow log
    with open(results_dir / "workflow.log", "w") as f:
        f.write(team.get_workflow_log())
    
    # Save summary
    with open(results_dir / "summary.md", "w") as f:
        f.write(team.get_summary())
    
    # Save communication history
    with open(results_dir / "communication.log", "w") as f:
        f.write(team.get_communication_history())
    
    return team


# ============= EXAMPLE 4: Django Integration =============
"""
Integrate with Django project

In your Django app:
    # views.py
"""

def django_create_app_view(request):
    """Django view for creating apps via multi-agent"""
    from django.http import JsonResponse
    from django.views.decorators.http import require_http_methods
    import json
    
    @require_http_methods(["POST"])
    def create_app(request):
        try:
            data = json.loads(request.body)
            
            team = MultiAgentTeam(team_name=data.get('name', 'App') + " Team")
            team.add_agent(ArchitectAgent())
            team.add_agent(DeveloperAgent())
            team.add_agent(TesterAgent())
            team.add_agent(ReviewerAgent())
            team.add_agent(DevOpsAgent())
            
            team.create_app_request(
                name=data.get('name'),
                description=data.get('description'),
                features=data.get('features', []),
                tech_stack=data.get('tech_stack', [])
            )
            
            results = team.execute_workflow()
            
            return JsonResponse({
                'status': 'success',
                'summary': team.get_summary(),
                'logs': team.get_workflow_log()
            })
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=400)
    
    return create_app(request)


# ============= EXAMPLE 5: FastAPI Integration =============
"""
Integrate with FastAPI

Create: agent_service.py
"""

try:
    from fastapi import FastAPI, HTTPException
    from pydantic import BaseModel
    from typing import List
    
    app_api = FastAPI(title="Multi-Agent System API")
    
    class AppRequest(BaseModel):
        name: str
        description: str
        features: List[str] = []
        tech_stack: List[str] = []
    
    @app_api.post("/api/v1/create-app")
    async def create_app_endpoint(app_req: AppRequest):
        """Create application via multi-agent system"""
        try:
            team = MultiAgentTeam(team_name=f"{app_req.name} Team")
            
            # Setup team
            team.add_agent(ArchitectAgent())
            team.add_agent(DeveloperAgent())
            team.add_agent(TesterAgent())
            team.add_agent(ReviewerAgent())
            team.add_agent(DevOpsAgent())
            
            # Create and execute
            team.create_app_request(
                name=app_req.name,
                description=app_req.description,
                features=app_req.features,
                tech_stack=app_req.tech_stack
            )
            
            results = team.execute_workflow()
            
            return {
                "status": "success",
                "app_name": team.app_request.name,
                "workflow_summary": team.get_summary(),
                "agent_count": len(team.agents)
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    
    @app_api.get("/api/v1/agents")
    async def list_agents():
        """Get available agents"""
        return {
            "agents": [
                {"name": "Alex", "role": "Architect"},
                {"name": "Bob", "role": "Developer"},
                {"name": "Charlie", "role": "Tester"},
                {"name": "Diana", "role": "Reviewer"},
                {"name": "Frank", "role": "DevOps"}
            ]
        }
    
except ImportError:
    pass


# ============= EXAMPLE 6: Async Integration =============
"""
Use multi-agent system with async operations
"""

import asyncio
from concurrent.futures import ThreadPoolExecutor

async def async_app_creation(app_config: dict, executor=None):
    """Create app asynchronously"""
    if executor is None:
        executor = ThreadPoolExecutor(max_workers=2)
    
    loop = asyncio.get_event_loop()
    
    def create_app_sync():
        team = MultiAgentTeam(team_name=f"{app_config['name']} Team")
        team.add_agent(ArchitectAgent())
        team.add_agent(DeveloperAgent())
        team.add_agent(TesterAgent())
        team.add_agent(ReviewerAgent())
        team.add_agent(DevOpsAgent())
        
        team.create_app_request(
            name=app_config['name'],
            description=app_config.get('description', ''),
            features=app_config.get('features', []),
            tech_stack=app_config.get('tech_stack', [])
        )
        
        return team.execute_workflow()
    
    # Run in thread pool
    results = await loop.run_in_executor(executor, create_app_sync)
    return results


# ============= EXAMPLE 7: Monitoring Integration =============
"""
Integrate with monitoring/logging systems
"""

def setup_monitoring(team: MultiAgentTeam):
    """Setup monitoring for team execution"""
    import logging
    
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    logger = logging.getLogger("MultiAgentSystem")
    
    # Log team composition
    logger.info(f"Team: {team.team_name}")
    for agent in team.agents.values():
        logger.info(f"  - {agent.name} ({agent.role.value})")
    
    # Log app request
    if team.app_request:
        logger.info(f"App Request: {team.app_request.name}")
        logger.info(f"Tech Stack: {', '.join(team.app_request.tech_stack)}")
    
    return logger


# ============= EXAMPLE 8: Database Integration =============
"""
Store workflow results in database
"""

def save_workflow_to_db(team: MultiAgentTeam, db_session):
    """Save workflow execution to database"""
    
    # Pseudocode - adapt to your DB
    workflow_record = {
        'id': team.app_request.id,
        'name': team.app_request.name,
        'description': team.app_request.description,
        'team_name': team.team_name,
        'agent_count': len(team.agents),
        'workflow_log': team.get_workflow_log(),
        'communication_log': team.get_communication_history(),
        'status': 'completed',
        'created_at': team.created_at
    }
    
    # db_session.save(workflow_record)
    # db_session.commit()
    
    return workflow_record


if __name__ == "__main__":
    # Example usage
    print("🤖 Multi-Agent Integration Examples")
    print("=" * 60)
    print("\nSee code comments for integration examples:")
    print("- CLI Integration")
    print("- Web API (Flask)")
    print("- Project Integration")
    print("- Django Integration")
    print("- FastAPI Integration")
    print("- Async Integration")
    print("- Monitoring Integration")
    print("- Database Integration")
