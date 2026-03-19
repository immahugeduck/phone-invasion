import { useState } from 'react'

const tabs = ['Scan', 'Network', 'Privacy', 'Trackers', 'RF Shield', 'Files', 'AI Report']

export default function App() {
  const [activeTab, setActiveTab] = useState('Scan')

  return (
    <div style={{ fontFamily: 'sans-serif', maxWidth: 480, margin: '0 auto' }}>
      <header style={{ background: '#0a0a0a', color: '#fff', padding: '16px', textAlign: 'center' }}>
        <h1>SHIELD·AI</h1>
      </header>

      <nav style={{ display: 'flex', overflowX: 'auto', background: '#111', gap: 4, padding: 8 }}>
        {tabs.map(tab => (
          <button
            key={tab}
            onClick={() => setActiveTab(tab)}
            style={{
              padding: '8px 14px',
              borderRadius: 8,
              border: 'none',
              background: activeTab === tab ? '#2563eb' : '#222',
              color: '#fff',
              cursor: 'pointer',
              whiteSpace: 'nowrap'
            }}
          >
            {tab}
          </button>
        ))}
      </nav>

      <main style={{ padding: 20 }}>
        <h2>{activeTab}</h2>
        <p style={{ color: '#666' }}>{activeTab} module — coming soon.</p>
      </main>
    </div>
  )
}
