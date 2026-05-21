import React, { useState, useEffect, useCallback } from 'react';
import './App.css';
import Sidebar from './components/Sidebar';
import AgentRoster from './components/AgentRoster';
import PlanViewer from './components/PlanViewer';
import ActivityLog from './components/ActivityLog';
import DiffPreview from './components/DiffPreview';
import ComposerPanel from './components/ComposerPanel';
import OverviewPanel from './components/OverviewPanel';

const API = process.env.REACT_APP_BACKEND_URL;

function App() {
  const [activePanel, setActivePanel] = useState('overview');
  const [agents, setAgents] = useState([]);
  const [plans, setPlans] = useState([]);
  const [activity, setActivity] = useState([]);
  const [diffs, setDiffs] = useState([]);
  const [providers, setProviders] = useState([]);
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchData = useCallback(async () => {
    try {
      const [agentsRes, plansRes, activityRes, diffsRes, providersRes, statsRes] = await Promise.all([
        fetch(`${API}/api/agents`),
        fetch(`${API}/api/plans`),
        fetch(`${API}/api/activity`),
        fetch(`${API}/api/diff`),
        fetch(`${API}/api/providers`),
        fetch(`${API}/api/stats`),
      ]);
      setAgents(await agentsRes.json());
      setPlans(await plansRes.json());
      setActivity(await activityRes.json());
      setDiffs(await diffsRes.json());
      setProviders(await providersRes.json());
      setStats(await statsRes.json());
    } catch (err) {
      console.error('Fetch error:', err);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  const renderPanel = () => {
    switch (activePanel) {
      case 'agents': return <AgentRoster agents={agents} />;
      case 'plans': return <PlanViewer plans={plans} />;
      case 'activity': return <ActivityLog entries={activity} />;
      case 'diff': return <DiffPreview diffs={diffs} />;
      case 'composer': return <ComposerPanel />;
      default: return <OverviewPanel stats={stats} agents={agents} providers={providers} />;
    }
  };

  if (loading) {
    return (
      <div data-testid="loading-screen" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh', color: 'var(--accent)', fontFamily: 'var(--font-heading)' }}>
        CURSOR ING loading...
      </div>
    );
  }

  return (
    <div data-testid="app-root" className="app-layout">
      <Sidebar activePanel={activePanel} onNavigate={setActivePanel} />
      <main data-testid="main-content" className="main-content">
        {renderPanel()}
      </main>
    </div>
  );
}

export default App;
