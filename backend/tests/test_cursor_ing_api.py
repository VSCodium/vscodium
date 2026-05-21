"""
Cursor ING Phase 1 API Tests
Tests all backend endpoints for the preview dashboard.
"""

import pytest
import requests
import os

BASE_URL = os.environ.get('REACT_APP_BACKEND_URL', '').rstrip('/')

class TestHealthEndpoint:
    """Health check endpoint tests"""
    
    def test_health_returns_ok(self):
        """GET /api/health returns correct structure"""
        response = requests.get(f"{BASE_URL}/api/health")
        assert response.status_code == 200
        
        data = response.json()
        assert data["status"] == "ok"
        assert data["product"] == "Cursor ING"
        assert data["phase"] == 1
        assert data["version"] == "0.1.0"
        assert data["telemetry"] == False


class TestAgentsEndpoint:
    """Agent roster endpoint tests"""
    
    def test_get_agents_returns_5_agents(self):
        """GET /api/agents returns 5 agents with correct fields"""
        response = requests.get(f"{BASE_URL}/api/agents")
        assert response.status_code == 200
        
        agents = response.json()
        assert len(agents) == 5
        
        # Verify all required fields exist for each agent
        required_fields = ["id", "name", "role", "status", "icon", "color", "permissions", "tools"]
        for agent in agents:
            for field in required_fields:
                assert field in agent, f"Agent {agent.get('id', 'unknown')} missing field: {field}"
    
    def test_agents_have_correct_ids(self):
        """Verify agent IDs match expected roster"""
        response = requests.get(f"{BASE_URL}/api/agents")
        agents = response.json()
        
        expected_ids = {"planner", "coder", "reviewer", "security", "browser"}
        actual_ids = {agent["id"] for agent in agents}
        assert actual_ids == expected_ids
    
    def test_get_single_agent(self):
        """GET /api/agents/{id} returns specific agent"""
        response = requests.get(f"{BASE_URL}/api/agents/planner")
        assert response.status_code == 200
        
        agent = response.json()
        assert agent["id"] == "planner"
        assert agent["name"] == "Planner"
        assert agent["role"] == "planner"


class TestPlansEndpoint:
    """Plan viewer endpoint tests"""
    
    def test_get_plans_returns_plan_with_steps(self):
        """GET /api/plans returns plans with steps containing required fields"""
        response = requests.get(f"{BASE_URL}/api/plans")
        assert response.status_code == 200
        
        plans = response.json()
        assert len(plans) >= 1
        
        plan = plans[0]
        assert "steps" in plan
        assert len(plan["steps"]) == 5
        
        # Verify step fields
        required_step_fields = ["id", "description", "status", "files", "risk", "agentId"]
        for step in plan["steps"]:
            for field in required_step_fields:
                assert field in step, f"Step {step.get('id', 'unknown')} missing field: {field}"
    
    def test_plan_has_correct_structure(self):
        """Verify plan has all required metadata"""
        response = requests.get(f"{BASE_URL}/api/plans")
        plan = response.json()[0]
        
        assert "id" in plan
        assert "title" in plan
        assert "description" in plan
        assert "status" in plan
        assert "createdAt" in plan
        assert "createdBy" in plan


class TestActivityEndpoint:
    """Activity log endpoint tests"""
    
    def test_get_activity_returns_18_entries(self):
        """GET /api/activity returns 18 activity log entries"""
        response = requests.get(f"{BASE_URL}/api/activity")
        assert response.status_code == 200
        
        entries = response.json()
        assert len(entries) == 18
    
    def test_activity_entries_have_required_fields(self):
        """Verify activity entries have timestamp/actor/category/message/severity"""
        response = requests.get(f"{BASE_URL}/api/activity")
        entries = response.json()
        
        required_fields = ["timestamp", "actor", "category", "message", "severity"]
        for entry in entries:
            for field in required_fields:
                assert field in entry, f"Entry {entry.get('id', 'unknown')} missing field: {field}"


class TestDiffEndpoint:
    """Diff preview endpoint tests"""
    
    def test_get_diff_returns_diff_with_hunks(self):
        """GET /api/diff returns diff with hunks containing required fields"""
        response = requests.get(f"{BASE_URL}/api/diff")
        assert response.status_code == 200
        
        diffs = response.json()
        assert len(diffs) >= 1
        
        diff = diffs[0]
        assert "hunks" in diff
        assert len(diff["hunks"]) >= 1
        
        # Verify hunk fields
        hunk = diff["hunks"][0]
        assert "filePath" in hunk
        assert "oldContent" in hunk
        assert "newContent" in hunk


class TestProvidersEndpoint:
    """Provider registry endpoint tests"""
    
    def test_get_providers_returns_5_providers(self):
        """GET /api/providers returns 5 providers (1 active mock, 4 planned)"""
        response = requests.get(f"{BASE_URL}/api/providers")
        assert response.status_code == 200
        
        providers = response.json()
        assert len(providers) == 5
        
        # Count active vs planned
        active = [p for p in providers if p["status"] == "active"]
        planned = [p for p in providers if p["status"] == "planned"]
        
        assert len(active) == 1
        assert len(planned) == 4
        
        # Verify mock provider is active
        mock_provider = next((p for p in providers if p["id"] == "mock"), None)
        assert mock_provider is not None
        assert mock_provider["status"] == "active"


class TestComposerChatEndpoint:
    """Composer chat endpoint tests"""
    
    def test_chat_with_plan_keyword(self):
        """POST /api/composer/chat with 'plan' returns plan response"""
        response = requests.post(
            f"{BASE_URL}/api/composer/chat",
            json={"message": "Create a plan for authentication"}
        )
        assert response.status_code == 200
        
        data = response.json()
        assert "response" in data
        assert "plan" in data["response"].lower() or "step" in data["response"].lower()
        assert data["model"] == "cursor-ing-mock-v1"
        assert data["provider"] == "mock"
    
    def test_chat_with_code_keyword(self):
        """POST /api/composer/chat with 'code' returns code response"""
        response = requests.post(
            f"{BASE_URL}/api/composer/chat",
            json={"message": "Write some code for me"}
        )
        assert response.status_code == 200
        
        data = response.json()
        assert "response" in data
        assert "```" in data["response"]  # Code block present
    
    def test_chat_with_security_keyword(self):
        """POST /api/composer/chat with 'security' returns security response"""
        response = requests.post(
            f"{BASE_URL}/api/composer/chat",
            json={"message": "Run a security scan"}
        )
        assert response.status_code == 200
        
        data = response.json()
        assert "response" in data
        assert "security" in data["response"].lower()
    
    def test_chat_default_response(self):
        """POST /api/composer/chat with generic message returns default response"""
        response = requests.post(
            f"{BASE_URL}/api/composer/chat",
            json={"message": "Hello"}
        )
        assert response.status_code == 200
        
        data = response.json()
        assert "response" in data
        assert "mock provider" in data["response"].lower()


class TestScaffoldValidateEndpoint:
    """Scaffold validation endpoint tests"""
    
    def test_scaffold_validate_passes(self):
        """GET /api/scaffold/validate returns passed=true with 59 checks"""
        response = requests.get(f"{BASE_URL}/api/scaffold/validate")
        assert response.status_code == 200
        
        data = response.json()
        assert data["passed"] == True
        assert data["exitCode"] == 0
        # Iteration 3: validation expanded to 59 checks (was 53 in iteration 1-2)
        assert "59 passed" in data["output"]


class TestStatsEndpoint:
    """Stats endpoint tests"""
    
    def test_get_stats(self):
        """GET /api/stats returns scaffold statistics"""
        response = requests.get(f"{BASE_URL}/api/stats")
        assert response.status_code == 200
        
        stats = response.json()
        assert stats["totalFiles"] == 53
        assert stats["agentDefinitions"] == 5
        assert stats["activityEntries"] == 18
