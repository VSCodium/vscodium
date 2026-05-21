import React, { useState, useEffect, useCallback } from 'react';
import './App.css';
import TitleBar from './components/TitleBar';
import ActivityBar from './components/ActivityBar';
import SidebarPanel from './components/SidebarPanel';
import EditorTabs from './components/EditorTabs';
import EditorArea from './components/EditorArea';
import ComposerPanel from './components/ComposerPanel';
import BottomPanel from './components/BottomPanel';
import StatusBar from './components/StatusBar';

const API = process.env.REACT_APP_BACKEND_URL;

function App() {
  const [sidebarView, setSidebarView] = useState('explorer');
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [composerOpen, setComposerOpen] = useState(true);
  const [bottomOpen, setBottomOpen] = useState(true);
  const [bottomTab, setBottomTab] = useState('activity');
  const [openTabs, setOpenTabs] = useState([
    { id: 'welcome', label: 'Welcome', type: 'welcome' },
    { id: 'plan', label: 'auth-module.plan', type: 'plan' },
  ]);
  const [activeTab, setActiveTab] = useState('welcome');
  const [agents, setAgents] = useState([]);
  const [plan, setPlan] = useState(null);
  const [activity, setActivity] = useState([]);
  const [diff, setDiff] = useState(null);
  const [providers, setProviders] = useState([]);
  const [stats, setStats] = useState(null);

  const fetchData = useCallback(async () => {
    try {
      const [ag, pl, ac, df, pr, st] = await Promise.all([
        fetch(`${API}/api/agents`).then(r => r.json()),
        fetch(`${API}/api/plans`).then(r => r.json()),
        fetch(`${API}/api/activity`).then(r => r.json()),
        fetch(`${API}/api/diff`).then(r => r.json()),
        fetch(`${API}/api/providers`).then(r => r.json()),
        fetch(`${API}/api/stats`).then(r => r.json()),
      ]);
      setAgents(ag);
      setPlan(pl[0] || null);
      setActivity(ac);
      setDiff(df[0] || null);
      setProviders(pr);
      setStats(st);
    } catch (err) {
      console.error('Fetch error:', err);
    }
  }, []);

  useEffect(() => { fetchData(); }, [fetchData]);

  const openTab = useCallback((id, label, type) => {
    if (!openTabs.find(t => t.id === id)) {
      setOpenTabs(prev => [...prev, { id, label, type }]);
    }
    setActiveTab(id);
  }, [openTabs]);

  const closeTab = useCallback((id) => {
    setOpenTabs(prev => {
      const next = prev.filter(t => t.id !== id);
      if (activeTab === id && next.length > 0) {
        setActiveTab(next[next.length - 1].id);
      }
      return next;
    });
  }, [activeTab]);

  const toggleSidebar = (view) => {
    if (sidebarView === view && sidebarOpen) {
      setSidebarOpen(false);
    } else {
      setSidebarView(view);
      setSidebarOpen(true);
    }
  };

  return (
    <div data-testid="ide-root" className="ide-shell">
      <TitleBar />
      <div className="ide-body">
        <ActivityBar
          active={sidebarOpen ? sidebarView : null}
          onSelect={toggleSidebar}
          composerOpen={composerOpen}
          onToggleComposer={() => setComposerOpen(p => !p)}
        />
        {sidebarOpen && (
          <SidebarPanel
            view={sidebarView}
            agents={agents}
            plan={plan}
            onOpenTab={openTab}
          />
        )}
        <div className="ide-center">
          <EditorTabs
            tabs={openTabs}
            activeTab={activeTab}
            onSelect={setActiveTab}
            onClose={closeTab}
          />
          <EditorArea
            activeTab={activeTab}
            plan={plan}
            diff={diff}
            stats={stats}
            agents={agents}
            providers={providers}
          />
          {bottomOpen && (
            <BottomPanel
              activeTab={bottomTab}
              onTabChange={setBottomTab}
              activity={activity}
              onClose={() => setBottomOpen(false)}
            />
          )}
        </div>
        {composerOpen && <ComposerPanel onClose={() => setComposerOpen(false)} />}
      </div>
      <StatusBar
        providers={providers}
        agents={agents}
        bottomOpen={bottomOpen}
        onToggleBottom={() => setBottomOpen(p => !p)}
      />
    </div>
  );
}

export default App;
