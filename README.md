# Phone Invasion

**Phone Invasion** is an iOS security and privacy tool that helps you detect and block threats on your device and network, including:

- 📡 **Rogue Cell Towers** – Identify potential IMSI catchers / cell-site simulators nearby  
- 🌐 **Network Status** – Monitor your connection type and security  
- 👁️ **Tracker Detection & Blocking** – Find and block tracking domains  
- 📁 **File Scanner** – Quarantine suspicious files on your device  
- 📶 **RF Shield** – Scan for unusual radio-frequency signals  
- 🔒 **Privacy Controls** – Kill switches and exposure-score dashboard  

---

## Project Structure

```
phone-invasion/
├── PhoneInvasion/                   ← iOS app target
│   ├── App/
│   │   ├── PhoneInvasionApp.swift   ← @main App entry point
│   │   └── ContentView.swift        ← Tab-bar navigation
│   ├── Models/
│   │   └── RogueTowerModels.swift   ← Data models (RogueTower, ScanResult, …)
│   ├── Views/
│   │   ├── ScanView.swift           ← Animated scan orb + threat summary
│   │   ├── NetworkView.swift        ← Network connection monitor
│   │   ├── TrackersView.swift       ← Tracker detection & blocking
│   │   ├── FilesView.swift          ← File quarantine manager
│   │   ├── RFShieldView.swift       ← RF signal scanner
│   │   └── PrivacyView.swift        ← Privacy kill switches & exposure score
│   ├── Services/
│   │   └── RogueTowerDetector.swift ← Detection engine + scan orchestrator
│   └── Supporting/
│       └── Info.plist               ← App permissions and metadata
├── project.yml                      ← XcodeGen project specification
├── LICENSE
└── README.md
```

---

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 15+ |
| iOS Deployment Target | 16.0+ |
| Swift | 5.9+ |

---

## Getting Started

### Option A — XcodeGen (recommended)

[XcodeGen](https://github.com/yonaskolb/XcodeGen) generates the Xcode project from `project.yml`, which keeps the repository clean.

```bash
# Install XcodeGen (once)
brew install xcodegen

# Generate the Xcode project
cd phone-invasion
xcodegen generate

# Open in Xcode
open PhoneInvasion.xcodeproj
```

### Option B — Manual Xcode Project

1. Open Xcode and choose **File → New → Project**  
2. Select **App** under the iOS tab  
3. Set **Product Name** to `PhoneInvasion`, **Interface** to `SwiftUI`, **Language** to `Swift`  
4. Delete the generated stub files and drag in the `PhoneInvasion/` folder from this repo  
5. Build and run (⌘R)

---

## Features Overview

### Scan View
An animated "orb" that pulses while scanning. After a scan completes it shows a colour-coded threat summary card — green for all-clear, red when threats are found.

### Network View
Displays current connectivity (WiFi / Cellular / None) and connection security. Backed by `NWPathMonitor` in production.

### Tracker Detection
Lists known trackers discovered on the device or network. Blocking removes entries from the list; in production this integrates with a DNS-based blocklist.

### File Scanner
Scans device storage for suspicious files and lets you quarantine or release them.

### RF Shield
Scans radio-frequency bands (700 MHz, 1.9 GHz, 2.4 GHz, 5.8 GHz) and highlights suspicious signals.

### Privacy Controls
Toggle location tracking, ad tracking, analytics sharing, background refresh, and third-party data sharing. An exposure-score gauge updates in real time.

---

## Roadmap

- [ ] Integrate `CoreTelephony` for real cell-tower data  
- [ ] Connect to a live rogue-tower database (e.g., OpenCelliD)  
- [ ] DNS-based tracker blocking via `NEDNSProxyProvider`  
- [ ] Real file-system scanning via `FileManager`  
- [ ] Push notifications when new threats are detected  
- [ ] iCloud sync for threat history  

---

## License

GNU General Public License v3.0 — see [LICENSE](LICENSE) for details.
