import React from 'react';
import WelcomeEditor from './editors/WelcomeEditor';
import PlanEditor from './editors/PlanEditor';
import DiffEditor from './editors/DiffEditor';

function EditorArea({ activeTab, plan, diff, stats, agents, providers }) {
  switch (activeTab) {
    case 'plan':
      return <PlanEditor plan={plan} />;
    case 'diff':
      return <DiffEditor diff={diff} />;
    case 'welcome':
    default:
      return <WelcomeEditor stats={stats} agents={agents} providers={providers} />;
  }
}

export default EditorArea;
