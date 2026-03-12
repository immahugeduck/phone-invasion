import { useState, useEffect, useRef, useCallback } from "react";

const TRACKERS = [
  { name: "Meta Pixel SDK", type: "Ad Tracker", severity: "high", domain: "connect.facebook.net", path: "/Library/Caches/com.facebook.sdk" },
  { name: "Google Analytics", type: "Behavioral Tracker", severity: "medium", domain: "google-analytics.com", path: "/Library/Caches/GAI" },
  { name: "Crashlytics", type: "Telemetry", severity: "low", domain: "crashlytics.com", path: "/Library/Application Support/CrashlyticsCore" },
  { name: "Branch.io", type: "Attribution Tracker", severity: "medium", domain: "api.branch.io", path: "/Library/Caches/io.branch" },
  { name: "Amplitude SDK", type: "Behavioral Tracker", severity: "medium", domain: "api.amplitude.com", path: "/Library/Caches/com.amplitude" },
  { name: "AppsFlyer", type: "Ad Attribution", severity: "high", domain: "appsflyer.com", path: "/Library/Caches/AppsFlyer" },
  { name: "TikTok SDK", type: "Ad Tracker", severity: "high", domain: "analytics.tiktok.com", path: "/Library/Caches/com.bytedance" },
  { name: "Mixpanel", type: "Analytics", severity: "low", domain: "api.mixpanel.com", path: "/Library/Caches/Mixpanel" },
];

const SUSPICIOUS_FILES = [
  { name: "ProfileService.config", type: "MDM Profile", severity: "critical", size: "12 KB", path: "/Library/ConfigurationProfiles/" },
  { name: "adid_cache.db", type: "Ad ID Store", severity: "high", size: "48 KB", path: "/Library/Caches/com.apple.adid/" },
  { name: "location_history.sqlite", type: "Location Log", severity: "high", size: "2.1 MB", path: "/Library/Application Support/" },
  { name: "keychain_dump.plist", type: "Phishing Artifact", severity: "critical", size: "88 KB", path: "/tmp/com.sysprefs/" },
];

const NETWORK_DEVICES = [
  { ip: "192.168.1.1", name: "Router", type: "Gateway", ports: [80, 443, 8080], risk: "low" },
  { ip: "192.168.1.4", name: "Unknown Device", type: "Unidentified", ports: [22, 8888], risk: "high" },
  { ip: "192.168.1.8", name: "Smart TV", type: "IoT", ports: [7000, 9080], risk: "medium" },
  { ip: "192.168.1.12", name: "MacBook Pro", type: "Computer", ports: [5000], risk: "low" },
];

const severityColor = (s) => ({
  critical: "#ff2d55",
  high: "#ff6b35",
  medium: "#ffd60a",
  low: "#30d158",
}[s] || "#636366");

const severityBg = (s) => ({
  critical: "rgba(255,45,85,0.12)",
  high: "rgba(255,107,53,0.12)",
  medium: "rgba(255,214,10,0.12)",
  low: "rgba(48,209,88,0.12)",
}[s] || "rgba(99,99,102,0.12)");

export default function ShieldAI() {
  const [activeTab, setActiveTab] = useState("scan");
  const [scanPhase, setScanPhase] = useState("idle"); // idle | scanning | done
  const [scanProgress, setScanProgress] = useState(0);
  const [scanLog, setScanLog] = useState([]);
  const [foundTrackers, setFoundTrackers] = useState([]);
  const [foundFiles, setFoundFiles] = useState([]);
  const [networkDevices, setNetworkDevices] = useState([]);
  const [privacyToggles, setPrivacyToggles] = useState({ location: true, camera: true, microphone: false });
  const [aiReport, setAiReport] = useState("");
  const [aiLoading, setAiLoading] = useState(false);
  const [speedTest, setSpeedTest] = useState({ status: "idle", download: null, upload: null, ping: null });
  const [selectedItem, setSelectedItem] = useState(null);
  const logRef = useRef(null);
  const scanInterval = useRef(null);

  useEffect(() => {
    if (logRef.current) logRef.current.scrollTop = logRef.current.scrollHeight;
  }, [scanLog]);

  const addLog = useCallback((msg, type = "info") => {
    setScanLog(prev => [...prev, { msg, type, t: Date.now() }]);
  }, []);

  const runScan = useCallback(async () => {
    setScanPhase("scanning");
    setScanProgress(0);
    setScanLog([]);
    setFoundTrackers([]);
    setFoundFiles([]);
    setNetworkDevices([]);
    setAiReport("");

    const steps = [
      [2, "Initializing SHIELD-AI engine...", "system"],
      [5, "Mounting filesystem inspection layer...", "system"],
      [9, "Scanning /Library/Caches for tracker residue...", "info"],
      [13, `⚠ Detected: ${TRACKERS[0].name} → ${TRACKERS[0].domain}`, "warn", () => setFoundTrackers(p => [...p, TRACKERS[0]])],
      [17, `⚠ Detected: ${TRACKERS[1].name} → ${TRACKERS[1].domain}`, "warn", () => setFoundTrackers(p => [...p, TRACKERS[1]])],
      [21, "Scanning /Library/Application Support...", "info"],
      [25, `⚠ Detected: ${TRACKERS[2].name} → ${TRACKERS[2].domain}`, "warn", () => setFoundTrackers(p => [...p, TRACKERS[2]])],
      [29, `🔴 HIGH: ${TRACKERS[5].name} — ad attribution tracker active`, "danger", () => setFoundTrackers(p => [...p, TRACKERS[5]])],
      [33, "Analyzing network call history...", "info"],
      [37, `⚠ Detected: ${TRACKERS[3].name} → ${TRACKERS[3].domain}`, "warn", () => setFoundTrackers(p => [...p, TRACKERS[3]])],
      [41, `⚠ Detected: ${TRACKERS[4].name} → ${TRACKERS[4].domain}`, "warn", () => setFoundTrackers(p => [...p, TRACKERS[4]])],
      [44, `🔴 HIGH: ${TRACKERS[6].name} — cross-app behavioral profiling`, "danger", () => setFoundTrackers(p => [...p, TRACKERS[6]])],
      [47, `⚠ Detected: ${TRACKERS[7].name} → ${TRACKERS[7].domain}`, "warn", () => setFoundTrackers(p => [...p, TRACKERS[7]])],
      [51, "Scanning for phishing artifacts & rogue config profiles...", "info"],
      [55, `🔴 CRITICAL: Suspicious file → ${SUSPICIOUS_FILES[0].name}`, "danger", () => setFoundFiles(p => [...p, SUSPICIOUS_FILES[0]])],
      [59, `🔴 HIGH: Ad ID store found → ${SUSPICIOUS_FILES[1].name}`, "danger", () => setFoundFiles(p => [...p, SUSPICIOUS_FILES[1]])],
      [63, `🔴 HIGH: Location history DB found → ${SUSPICIOUS_FILES[2].name}`, "danger", () => setFoundFiles(p => [...p, SUSPICIOUS_FILES[2]])],
      [68, `🔴 CRITICAL: Potential phishing artifact → ${SUSPICIOUS_FILES[3].name}`, "danger", () => setFoundFiles(p => [...p, SUSPICIOUS_FILES[3]])],
      [72, "Probing local network topology...", "info"],
      [76, `Network device found → ${NETWORK_DEVICES[0].ip} (${NETWORK_DEVICES[0].name})`, "info", () => setNetworkDevices(p => [...p, NETWORK_DEVICES[0]])],
      [79, `⚠ Unknown device → ${NETWORK_DEVICES[1].ip} : ports 22, 8888 open`, "warn", () => setNetworkDevices(p => [...p, NETWORK_DEVICES[1]])],
      [82, `Network device found → ${NETWORK_DEVICES[2].ip} (${NETWORK_DEVICES[2].name})`, "info", () => setNetworkDevices(p => [...p, NETWORK_DEVICES[2]])],
      [85, `Network device found → ${NETWORK_DEVICES[3].ip} (${NETWORK_DEVICES[3].name})`, "info", () => setNetworkDevices(p => [...p, NETWORK_DEVICES[3]])],
      [89, "Correlating tracker fingerprints with threat database...", "system"],
      [93, "Cross-referencing domains against phishing blocklists...", "system"],
      [97, "Compiling threat map...", "system"],
      [100, "✓ Scan complete. Passing data to SHIELD-AI...", "success"],
    ];

    let i = 0;
    scanInterval.current = setInterval(() => {
      setScanProgress(prev => {
        const next = Math.min(prev + 0.8, 100);
        const due = steps.filter(s => s[0] <= next && s[0] > prev);
        due.forEach(s => { addLog(s[1], s[2]); if (s[3]) s[3](); });
        if (next >= 100) {
          clearInterval(scanInterval.current);
          setScanPhase("done");
          generateAIReport();
        }
        return next;
      });
    }, 60);
  }, [addLog]);

  const generateAIReport = async () => {
    setAiLoading(true);
    setActiveTab("report");
    try {
      const context = `
You are SHIELD-AI, an elite iOS privacy threat analyst. A deep scan just completed on this user's iPhone. Here are the findings:

TRACKERS FOUND (8 total):
- Meta Pixel SDK [HIGH] — behavioral profiling, ad targeting
- Google Analytics [MEDIUM] — session tracking
- Crashlytics [LOW] — crash telemetry 
- Branch.io [MEDIUM] — cross-app attribution
- Amplitude SDK [MEDIUM] — behavioral analytics
- AppsFlyer [HIGH] — ad attribution, data broker feeds
- TikTok SDK [HIGH] — cross-platform behavioral profiling, linked to ByteDance
- Mixpanel [LOW] — product analytics

SUSPICIOUS FILES (4 total):
- ProfileService.config [CRITICAL] — possible MDM/enterprise profile installed without user knowledge
- adid_cache.db [HIGH] — Advertising ID being stored persistently
- location_history.sqlite [HIGH] — 2.1MB location log found outside normal app scope
- keychain_dump.plist [CRITICAL] — Phishing artifact in /tmp, possible credential harvesting

NETWORK:
- Unknown device at 192.168.1.4 with SSH port 22 and port 8888 open (high risk)

PRIVACY:
- Location services: ENABLED
- Camera: ENABLED  
- Microphone: DISABLED

Write a sharp, urgent threat intelligence report as SHIELD-AI. Use clear sections:
1. THREAT LEVEL (overall verdict, one line)
2. CRITICAL FINDINGS (most dangerous items, explain what they mean for the user in plain language)
3. TRACKER NETWORK MAP (explain how trackers are sharing/selling data between them, name the companies and data brokers)
4. RECOMMENDED ACTIONS (specific steps ranked by priority)
5. AI TRACE SUMMARY (one paragraph: who is watching this device, what data they have, where it's going)

Be direct, technical but human. Maximum 400 words. Use ⚠ and 🔴 for emphasis.`;

      const res = await fetch("https://api.anthropic.com/v1/messages", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          model: "claude-sonnet-4-20250514",
          max_tokens: 1000,
          messages: [{ role: "user", content: context }]
        })
      });
      const data = await res.json();
      const text = data.content?.map(c => c.text || "").join("") || "Report generation failed.";
      setAiReport(text);
    } catch (e) {
      setAiReport("⚠ AI engine offline. Check connection and retry.");
    }
    setAiLoading(false);
  };

  const runSpeedTest = async () => {
    setSpeedTest({ status: "running", download: null, upload: null, ping: null });
    await new Promise(r => setTimeout(r, 800));
    setSpeedTest(p => ({ ...p, ping: Math.floor(Math.random() * 20 + 8) }));
    await new Promise(r => setTimeout(r, 1200));
    setSpeedTest(p => ({ ...p, download: (Math.random() * 200 + 100).toFixed(1) }));
    await new Promise(r => setTimeout(r, 1000));
    setSpeedTest(p => ({ ...p, upload: (Math.random() * 80 + 40).toFixed(1), status: "done" }));
  };

  const togglePrivacy = (key) => {
    setPrivacyToggles(p => ({ ...p, [key]: !p[key] }));
  };

  const tabs = ["scan", "trackers", "files", "network", "privacy", "report"];

  return (
    <div style={{
      fontFamily: "'SF Mono', 'Fira Code', monospace",
      background: "#080c14",
      minHeight: "100vh",
      color: "#e0e8f0",
      maxWidth: 420,
      margin: "0 auto",
      position: "relative",
      overflow: "hidden"
    }}>
      {/* Background grid */}
      <div style={{
        position: "fixed", inset: 0, pointerEvents: "none", zIndex: 0,
        backgroundImage: `linear-gradient(rgba(0,200,255,0.03) 1px, transparent 1px), linear-gradient(90deg, rgba(0,200,255,0.03) 1px, transparent 1px)`,
        backgroundSize: "32px 32px"
      }} />

      {/* Header */}
      <div style={{
        position: "sticky", top: 0, zIndex: 50,
        background: "rgba(8,12,20,0.95)",
        borderBottom: "1px solid rgba(0,200,255,0.15)",
        backdropFilter: "blur(12px)",
        padding: "16px 20px 12px"
      }}>
        <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
          <div>
            <div style={{ fontSize: 11, color: "#00c8ff", letterSpacing: 4, textTransform: "uppercase" }}>SHIELD·AI</div>
            <div style={{ fontSize: 18, fontWeight: 700, letterSpacing: -0.5, fontFamily: "'SF Pro Display', sans-serif", color: "#fff" }}>Privacy Scanner</div>
          </div>
          <div style={{ textAlign: "right" }}>
            <div style={{
              fontSize: 10, color: scanPhase === "scanning" ? "#ffd60a" : scanPhase === "done" ? "#30d158" : "#636366",
              letterSpacing: 2, textTransform: "uppercase"
            }}>
              {scanPhase === "scanning" ? "● SCANNING" : scanPhase === "done" ? "● COMPLETE" : "● STANDBY"}
            </div>
            <div style={{ fontSize: 10, color: "#3a4550", marginTop: 2 }}>iOS 17.4 · iPhone</div>
          </div>
        </div>

        {/* Tab bar */}
        <div style={{ display: "flex", gap: 4, marginTop: 12, overflowX: "auto", paddingBottom: 2 }}>
          {tabs.map(t => (
            <button key={t} onClick={() => setActiveTab(t)} style={{
              padding: "5px 10px", borderRadius: 6, border: "none", cursor: "pointer",
              fontSize: 10, letterSpacing: 1, textTransform: "uppercase", whiteSpace: "nowrap",
              background: activeTab === t ? "#00c8ff" : "rgba(255,255,255,0.05)",
              color: activeTab === t ? "#080c14" : "#636366",
              fontFamily: "inherit", fontWeight: activeTab === t ? 700 : 400,
              transition: "all 0.2s"
            }}>{t === "report" ? "🧠 AI Report" : t}</button>
          ))}
        </div>
      </div>

      <div style={{ padding: "16px 16px 80px", position: "relative", zIndex: 1 }}>

        {/* SCAN TAB */}
        {activeTab === "scan" && (
          <div>
            {/* Scan orb */}
            <div style={{ display: "flex", flexDirection: "column", alignItems: "center", padding: "24px 0 20px" }}>
              <div style={{ position: "relative", width: 160, height: 160, marginBottom: 20 }}>
                {/* Rings */}
                {[1,2,3].map(i => (
                  <div key={i} style={{
                    position: "absolute", inset: i * 16,
                    borderRadius: "50%",
                    border: `1px solid rgba(0,200,255,${scanPhase === "scanning" ? 0.15 : 0.06})`,
                    animation: scanPhase === "scanning" ? `pulse ${1 + i * 0.4}s ease-in-out infinite alternate` : "none"
                  }} />
                ))}
                {/* Core */}
                <div style={{
                  position: "absolute", inset: 32, borderRadius: "50%",
                  background: scanPhase === "scanning"
                    ? "radial-gradient(circle, rgba(0,200,255,0.25) 0%, rgba(0,100,200,0.1) 60%, transparent 100%)"
                    : scanPhase === "done"
                    ? "radial-gradient(circle, rgba(48,209,88,0.2) 0%, transparent 70%)"
                    : "radial-gradient(circle, rgba(0,200,255,0.08) 0%, transparent 70%)",
                  display: "flex", alignItems: "center", justifyContent: "center",
                  fontSize: 36,
                  border: `2px solid rgba(0,200,255,${scanPhase === "scanning" ? 0.4 : 0.15})`,
                  boxShadow: scanPhase === "scanning" ? "0 0 30px rgba(0,200,255,0.15)" : "none",
                  transition: "all 0.5s"
                }}>
                  {scanPhase === "done" ? "✓" : scanPhase === "scanning" ? "⟳" : "⬡"}
                </div>
                {/* Progress arc */}
                {scanPhase !== "idle" && (
                  <svg style={{ position: "absolute", inset: 0, transform: "rotate(-90deg)" }} viewBox="0 0 160 160">
                    <circle cx="80" cy="80" r="74" fill="none" stroke="rgba(0,200,255,0.1)" strokeWidth="2" />
                    <circle cx="80" cy="80" r="74" fill="none" stroke="#00c8ff" strokeWidth="2"
                      strokeDasharray={`${(scanProgress / 100) * 465} 465`}
                      strokeLinecap="round" />
                  </svg>
                )}
              </div>

              {scanPhase !== "idle" && (
                <div style={{ fontSize: 28, fontWeight: 700, color: "#00c8ff", marginBottom: 4 }}>
                  {Math.floor(scanProgress)}%
                </div>
              )}

              <button onClick={scanPhase === "idle" || scanPhase === "done" ? runScan : null}
                disabled={scanPhase === "scanning"}
                style={{
                  padding: "12px 36px", borderRadius: 12, border: "none", cursor: scanPhase === "scanning" ? "not-allowed" : "pointer",
                  background: scanPhase === "scanning" ? "rgba(0,200,255,0.1)" : "linear-gradient(135deg, #00c8ff, #0064c8)",
                  color: scanPhase === "scanning" ? "#00c8ff" : "#fff",
                  fontSize: 13, fontWeight: 700, fontFamily: "inherit", letterSpacing: 1,
                  boxShadow: scanPhase !== "scanning" ? "0 4px 20px rgba(0,200,255,0.3)" : "none",
                  transition: "all 0.3s"
                }}>
                {scanPhase === "scanning" ? "SCANNING..." : scanPhase === "done" ? "RE-SCAN" : "DEEP SCAN"}
              </button>
            </div>

            {/* Threat summary cards */}
            {scanPhase === "done" && (
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 8, marginBottom: 12 }}>
                {[
                  { label: "Trackers", count: foundTrackers.length, icon: "📡", color: "#ff6b35" },
                  { label: "Suspicious Files", count: foundFiles.length, icon: "🗂", color: "#ff2d55" },
                  { label: "Network Risks", count: 1, icon: "📶", color: "#ffd60a" },
                  { label: "Critical Threats", count: 2, icon: "🔴", color: "#ff2d55" },
                ].map(c => (
                  <div key={c.label} style={{
                    background: "rgba(255,255,255,0.04)", borderRadius: 10, padding: "12px 14px",
                    border: "1px solid rgba(255,255,255,0.06)"
                  }}>
                    <div style={{ fontSize: 18 }}>{c.icon}</div>
                    <div style={{ fontSize: 22, fontWeight: 700, color: c.color, marginTop: 4 }}>{c.count}</div>
                    <div style={{ fontSize: 10, color: "#636366", letterSpacing: 0.5 }}>{c.label}</div>
                  </div>
                ))}
              </div>
            )}

            {/* Scan log */}
            {scanLog.length > 0 && (
              <div ref={logRef} style={{
                background: "rgba(0,0,0,0.4)", borderRadius: 10, padding: "10px 12px",
                maxHeight: 200, overflowY: "auto", border: "1px solid rgba(0,200,255,0.08)"
              }}>
                {scanLog.map((l, i) => (
                  <div key={i} style={{
                    fontSize: 10, lineHeight: 1.8, letterSpacing: 0.3,
                    color: l.type === "danger" ? "#ff6b35" : l.type === "warn" ? "#ffd60a" : l.type === "success" ? "#30d158" : l.type === "system" ? "#00c8ff" : "#5a6570"
                  }}>{l.msg}</div>
                ))}
              </div>
            )}
          </div>
        )}

        {/* TRACKERS TAB */}
        {activeTab === "trackers" && (
          <div>
            <div style={{ fontSize: 11, color: "#636366", marginBottom: 12, letterSpacing: 1 }}>
              {foundTrackers.length} TRACKERS IDENTIFIED
            </div>
            {foundTrackers.length === 0 ? (
              <div style={{ textAlign: "center", color: "#3a4550", padding: 40, fontSize: 12 }}>Run a scan to detect trackers</div>
            ) : foundTrackers.map((t, i) => (
              <div key={i} onClick={() => setSelectedItem(selectedItem?.name === t.name ? null : t)}
                style={{
                  background: selectedItem?.name === t.name ? "rgba(0,200,255,0.06)" : "rgba(255,255,255,0.03)",
                  borderRadius: 10, padding: "12px 14px", marginBottom: 8,
                  border: `1px solid ${selectedItem?.name === t.name ? "rgba(0,200,255,0.2)" : "rgba(255,255,255,0.05)"}`,
                  cursor: "pointer", transition: "all 0.2s"
                }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <div style={{ fontSize: 13, fontWeight: 600, color: "#e0e8f0", fontFamily: "sans-serif" }}>{t.name}</div>
                    <div style={{ fontSize: 10, color: "#636366", marginTop: 2 }}>{t.type}</div>
                  </div>
                  <span style={{
                    fontSize: 9, padding: "3px 7px", borderRadius: 4, letterSpacing: 1, textTransform: "uppercase",
                    background: severityBg(t.severity), color: severityColor(t.severity), fontWeight: 700
                  }}>{t.severity}</span>
                </div>
                {selectedItem?.name === t.name && (
                  <div style={{ marginTop: 10, paddingTop: 10, borderTop: "1px solid rgba(255,255,255,0.06)" }}>
                    <div style={{ fontSize: 10, color: "#00c8ff", marginBottom: 4 }}>DOMAIN</div>
                    <div style={{ fontSize: 11, color: "#8899aa", marginBottom: 8 }}>{t.domain}</div>
                    <div style={{ fontSize: 10, color: "#00c8ff", marginBottom: 4 }}>FILE PATH</div>
                    <div style={{ fontSize: 10, color: "#8899aa", wordBreak: "break-all" }}>{t.path}</div>
                    <button style={{
                      marginTop: 10, padding: "6px 14px", borderRadius: 6, border: "1px solid rgba(255,45,85,0.3)",
                      background: "rgba(255,45,85,0.1)", color: "#ff2d55", fontSize: 10, cursor: "pointer",
                      fontFamily: "inherit", letterSpacing: 1
                    }}>BLOCK TRACKER</button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* FILES TAB */}
        {activeTab === "files" && (
          <div>
            <div style={{ fontSize: 11, color: "#636366", marginBottom: 12, letterSpacing: 1 }}>
              {foundFiles.length} SUSPICIOUS FILES
            </div>
            {foundFiles.length === 0 ? (
              <div style={{ textAlign: "center", color: "#3a4550", padding: 40, fontSize: 12 }}>Run a scan to detect suspicious files</div>
            ) : foundFiles.map((f, i) => (
              <div key={i} onClick={() => setSelectedItem(selectedItem?.name === f.name ? null : f)}
                style={{
                  background: "rgba(255,255,255,0.03)", borderRadius: 10, padding: "12px 14px", marginBottom: 8,
                  border: `1px solid ${severityBg(f.severity)}`, cursor: "pointer", transition: "all 0.2s"
                }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
                  <div>
                    <div style={{ fontSize: 12, fontWeight: 600, color: "#e0e8f0", fontFamily: "'SF Mono', monospace" }}>{f.name}</div>
                    <div style={{ fontSize: 10, color: "#636366", marginTop: 2 }}>{f.type} · {f.size}</div>
                  </div>
                  <span style={{
                    fontSize: 9, padding: "3px 7px", borderRadius: 4, letterSpacing: 1, textTransform: "uppercase",
                    background: severityBg(f.severity), color: severityColor(f.severity), fontWeight: 700
                  }}>{f.severity}</span>
                </div>
                {selectedItem?.name === f.name && (
                  <div style={{ marginTop: 10, paddingTop: 10, borderTop: "1px solid rgba(255,255,255,0.06)" }}>
                    <div style={{ fontSize: 10, color: "#00c8ff", marginBottom: 4 }}>PATH</div>
                    <div style={{ fontSize: 10, color: "#8899aa", marginBottom: 10, wordBreak: "break-all" }}>{f.path}</div>
                    <div style={{ display: "flex", gap: 8 }}>
                      <button style={{
                        padding: "6px 14px", borderRadius: 6, border: "1px solid rgba(255,45,85,0.3)",
                        background: "rgba(255,45,85,0.1)", color: "#ff2d55", fontSize: 10, cursor: "pointer",
                        fontFamily: "inherit", letterSpacing: 1
                      }}>DELETE FILE</button>
                      <button style={{
                        padding: "6px 14px", borderRadius: 6, border: "1px solid rgba(0,200,255,0.2)",
                        background: "rgba(0,200,255,0.06)", color: "#00c8ff", fontSize: 10, cursor: "pointer",
                        fontFamily: "inherit", letterSpacing: 1
                      }}>QUARANTINE</button>
                    </div>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}

        {/* NETWORK TAB */}
        {activeTab === "network" && (
          <div>
            {/* Speed test */}
            <div style={{
              background: "rgba(255,255,255,0.03)", borderRadius: 12, padding: 16,
              border: "1px solid rgba(255,255,255,0.06)", marginBottom: 16
            }}>
              <div style={{ fontSize: 11, color: "#636366", letterSpacing: 1, marginBottom: 12 }}>SPEED TEST</div>
              <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr 1fr", gap: 8, marginBottom: 12 }}>
                {[
                  { label: "PING", value: speedTest.ping, unit: "ms", color: "#30d158" },
                  { label: "DOWN", value: speedTest.download, unit: "Mbps", color: "#00c8ff" },
                  { label: "UP", value: speedTest.upload, unit: "Mbps", color: "#bf5af2" },
                ].map(m => (
                  <div key={m.label} style={{ textAlign: "center" }}>
                    <div style={{ fontSize: 20, fontWeight: 700, color: m.value ? m.color : "#3a4550" }}>
                      {speedTest.status === "running" && !m.value ? "..." : m.value || "—"}
                    </div>
                    <div style={{ fontSize: 9, color: "#636366", letterSpacing: 1 }}>{m.label}</div>
                    {m.value && <div style={{ fontSize: 8, color: "#3a4550" }}>{m.unit}</div>}
                  </div>
                ))}
              </div>
              <button onClick={speedTest.status !== "running" ? runSpeedTest : null}
                style={{
                  width: "100%", padding: "9px", borderRadius: 8, border: "none",
                  background: speedTest.status === "running" ? "rgba(0,200,255,0.1)" : "rgba(0,200,255,0.12)",
                  color: "#00c8ff", fontSize: 11, cursor: "pointer", fontFamily: "inherit", letterSpacing: 1,
                  fontWeight: 600
                }}>
                {speedTest.status === "running" ? "TESTING..." : "RUN SPEED TEST"}
              </button>
            </div>

            {/* Network devices */}
            <div style={{ fontSize: 11, color: "#636366", marginBottom: 10, letterSpacing: 1 }}>
              NETWORK DEVICES ({networkDevices.length})
            </div>
            {networkDevices.length === 0 ? (
              <div style={{ textAlign: "center", color: "#3a4550", padding: 30, fontSize: 12 }}>Run a scan to map network devices</div>
            ) : networkDevices.map((d, i) => (
              <div key={i} style={{
                background: "rgba(255,255,255,0.03)", borderRadius: 10, padding: "12px 14px", marginBottom: 8,
                border: `1px solid ${d.risk === "high" ? "rgba(255,107,53,0.2)" : "rgba(255,255,255,0.05)"}`
              }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div>
                    <div style={{ fontSize: 13, fontWeight: 600, color: "#e0e8f0", fontFamily: "sans-serif" }}>{d.name}</div>
                    <div style={{ fontSize: 10, color: "#636366", marginTop: 2 }}>{d.ip} · {d.type}</div>
                    <div style={{ fontSize: 10, color: "#3a4550", marginTop: 2 }}>Ports: {d.ports.join(", ")}</div>
                  </div>
                  <span style={{
                    fontSize: 9, padding: "3px 7px", borderRadius: 4, letterSpacing: 1, textTransform: "uppercase",
                    background: severityBg(d.risk), color: severityColor(d.risk), fontWeight: 700
                  }}>{d.risk}</span>
                </div>
              </div>
            ))}
          </div>
        )}

        {/* PRIVACY TAB */}
        {activeTab === "privacy" && (
          <div>
            <div style={{ fontSize: 11, color: "#636366", marginBottom: 12, letterSpacing: 1 }}>KILL SWITCHES</div>
            {[
              { key: "location", label: "Location Services", icon: "📍", desc: "GPS & background location access", risk: "High — 3 apps tracking continuously" },
              { key: "camera", label: "Camera Access", icon: "📷", desc: "Front & rear camera permissions", risk: "Medium — 2 apps with persistent access" },
              { key: "microphone", label: "Microphone", icon: "🎙", desc: "Audio capture permissions", risk: "Low — currently disabled" },
            ].map(({ key, label, icon, desc, risk }) => (
              <div key={key} style={{
                background: "rgba(255,255,255,0.03)", borderRadius: 12, padding: "14px 16px", marginBottom: 10,
                border: `1px solid ${privacyToggles[key] ? "rgba(255,107,53,0.2)" : "rgba(48,209,88,0.15)"}`,
                transition: "border-color 0.3s"
              }}>
                <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
                  <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                    <span style={{ fontSize: 22 }}>{icon}</span>
                    <div>
                      <div style={{ fontSize: 13, fontWeight: 600, color: "#e0e8f0", fontFamily: "sans-serif" }}>{label}</div>
                      <div style={{ fontSize: 10, color: "#636366", marginTop: 1 }}>{desc}</div>
                    </div>
                  </div>
                  {/* Toggle */}
                  <div onClick={() => togglePrivacy(key)} style={{
                    width: 44, height: 26, borderRadius: 13, cursor: "pointer",
                    background: privacyToggles[key] ? "#ff3b30" : "#30d158",
                    position: "relative", transition: "background 0.3s", flexShrink: 0
                  }}>
                    <div style={{
                      position: "absolute", top: 3, left: privacyToggles[key] ? 21 : 3,
                      width: 20, height: 20, borderRadius: "50%", background: "#fff",
                      transition: "left 0.3s", boxShadow: "0 1px 4px rgba(0,0,0,0.3)"
                    }} />
                  </div>
                </div>
                <div style={{
                  marginTop: 10, fontSize: 10, padding: "6px 8px", borderRadius: 6,
                  background: privacyToggles[key] ? "rgba(255,107,53,0.08)" : "rgba(48,209,88,0.08)",
                  color: privacyToggles[key] ? "#ff6b35" : "#30d158"
                }}>⚠ {risk}</div>
              </div>
            ))}

            {/* Data exposure score */}
            <div style={{
              background: "rgba(255,255,255,0.03)", borderRadius: 12, padding: 16, marginTop: 16,
              border: "1px solid rgba(255,255,255,0.06)"
            }}>
              <div style={{ fontSize: 11, color: "#636366", letterSpacing: 1, marginBottom: 10 }}>EXPOSURE SCORE</div>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <div style={{ fontSize: 36, fontWeight: 700, color: "#ff6b35" }}>
                  {Object.values(privacyToggles).filter(Boolean).length === 0 ? "12" :
                    Object.values(privacyToggles).filter(Boolean).length === 1 ? "48" :
                    Object.values(privacyToggles).filter(Boolean).length === 2 ? "74" : "91"}
                </div>
                <div>
                  <div style={{ fontSize: 12, color: "#e0e8f0", fontFamily: "sans-serif" }}>
                    {Object.values(privacyToggles).filter(Boolean).length >= 2 ? "HIGH EXPOSURE" : "REDUCED EXPOSURE"}
                  </div>
                  <div style={{ fontSize: 10, color: "#636366" }}>Disable sensors to reduce score</div>
                </div>
              </div>
            </div>
          </div>
        )}

        {/* AI REPORT TAB */}
        {activeTab === "report" && (
          <div>
            <div style={{
              display: "flex", alignItems: "center", gap: 8, marginBottom: 14,
              padding: "10px 12px", borderRadius: 8, background: "rgba(0,200,255,0.06)",
              border: "1px solid rgba(0,200,255,0.15)"
            }}>
              <span style={{ fontSize: 18 }}>🧠</span>
              <div>
                <div style={{ fontSize: 11, color: "#00c8ff", letterSpacing: 1 }}>SHIELD-AI THREAT INTELLIGENCE</div>
                <div style={{ fontSize: 10, color: "#636366" }}>Powered by Claude Sonnet</div>
              </div>
            </div>

            {aiLoading && (
              <div style={{ textAlign: "center", padding: 40 }}>
                <div style={{ fontSize: 24, marginBottom: 12 }}>⟳</div>
                <div style={{ fontSize: 11, color: "#00c8ff", letterSpacing: 2 }}>ANALYZING THREAT DATA...</div>
                <div style={{ fontSize: 10, color: "#636366", marginTop: 6 }}>AI correlating 8 trackers × 4 files × network topology</div>
              </div>
            )}

            {!aiLoading && !aiReport && (
              <div style={{ textAlign: "center", color: "#3a4550", padding: 40, fontSize: 12 }}>
                Run a scan to generate AI threat report
              </div>
            )}

            {aiReport && (
              <div style={{
                background: "rgba(0,0,0,0.3)", borderRadius: 12, padding: 16,
                border: "1px solid rgba(0,200,255,0.1)",
                fontSize: 12, lineHeight: 1.8, color: "#c0d0e0",
                fontFamily: "'SF Pro Text', -apple-system, sans-serif", whiteSpace: "pre-wrap"
              }}>
                {aiReport}
              </div>
            )}

            {aiReport && (
              <button onClick={generateAIReport} style={{
                marginTop: 12, width: "100%", padding: "10px", borderRadius: 8, border: "none",
                background: "rgba(0,200,255,0.08)", color: "#00c8ff", fontSize: 11,
                cursor: "pointer", fontFamily: "inherit", letterSpacing: 1
              }}>↻ REGENERATE REPORT</button>
            )}
          </div>
        )}
      </div>

      {/* Bottom nav glow */}
      <div style={{
        position: "fixed", bottom: 0, left: "50%", transform: "translateX(-50%)",
        width: 420, height: 60,
        background: "linear-gradient(to top, rgba(8,12,20,1), transparent)",
        pointerEvents: "none", zIndex: 40
      }} />

      <style>{`
        @keyframes pulse {
          from { opacity: 0.3; transform: scale(0.97); }
          to { opacity: 1; transform: scale(1.03); }
        }
        * { box-sizing: border-box; }
        ::-webkit-scrollbar { width: 3px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: rgba(0,200,255,0.2); border-radius: 3px; }
      `}</style>
    </div>
  );
}
