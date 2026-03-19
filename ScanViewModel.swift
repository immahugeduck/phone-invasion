import Foundation
import SwiftUI
import Combine

@MainActor
class ScanViewModel: ObservableObject {
    @Published var phase: ScanPhase = .idle
    @Published var progress: Double = 0
    @Published var logs: [ScanLogEntry] = []
    @Published var trackers: [Tracker] = []
    @Published var suspiciousFiles: [SuspiciousFile] = []
    @Published var networkDevices: [NetworkDevice] = []
    @Published var aiReport: String = ""
    @Published var aiLoading: Bool = false

    private var scanTask: Task<Void, Never>?

    // MARK: - Scan Steps
    private struct ScanStep {
        let progress: Double
        let message: String
        let logType: ScanLogEntry.LogType
        let action: (() -> Void)?
    }

    private func buildSteps() -> [ScanStep] {
        let trackers = TrackerDatabase.all
        let files = SuspiciousFilesDatabase.all

        return [
            ScanStep(progress: 2,  message: "Initializing SHIELD-AI engine v2.4...", logType: .system, action: nil),
            ScanStep(progress: 5,  message: "Mounting filesystem inspection layer...", logType: .system, action: nil),
            ScanStep(progress: 8,  message: "Loading threat signature database (47,293 entries)...", logType: .system, action: nil),
            ScanStep(progress: 12, message: "Scanning /Library/Caches for tracker residue...", logType: .info, action: nil),
            ScanStep(progress: 15, message: "⚠ Detected: \(trackers[0].name) → \(trackers[0].domain)", logType: .warning) { [weak self] in
                self?.trackers.append(trackers[0])
            },
            ScanStep(progress: 19, message: "⚠ Detected: \(trackers[1].name) → \(trackers[1].domain)", logType: .warning) { [weak self] in
                self?.trackers.append(trackers[1])
            },
            ScanStep(progress: 23, message: "Scanning /Library/Application Support...", logType: .info, action: nil),
            ScanStep(progress: 27, message: "⚠ Detected: \(trackers[2].name) — crash telemetry SDK active", logType: .warning) { [weak self] in
                self?.trackers.append(trackers[2])
            },
            ScanStep(progress: 31, message: "🔴 HIGH: \(trackers[5].name) — ad attribution + data broker feeds", logType: .danger) { [weak self] in
                self?.trackers.append(trackers[5])
            },
            ScanStep(progress: 35, message: "Analyzing embedded framework manifests...", logType: .info, action: nil),
            ScanStep(progress: 38, message: "⚠ Detected: \(trackers[3].name) → cross-app install attribution", logType: .warning) { [weak self] in
                self?.trackers.append(trackers[3])
            },
            ScanStep(progress: 42, message: "⚠ Detected: \(trackers[4].name) → behavioral analytics pipeline", logType: .warning) { [weak self] in
                self?.trackers.append(trackers[4])
            },
            ScanStep(progress: 46, message: "🔴 HIGH: \(trackers[6].name) — ByteDance cross-platform profiling", logType: .danger) { [weak self] in
                self?.trackers.append(trackers[6])
            },
            ScanStep(progress: 49, message: "⚠ Detected: \(trackers[7].name) → product analytics", logType: .warning) { [weak self] in
                self?.trackers.append(trackers[7])
            },
            ScanStep(progress: 53, message: "Scanning for rogue configuration profiles...", logType: .info, action: nil),
            ScanStep(progress: 57, message: "🔴 CRITICAL: Suspicious profile → \(files[0].name)", logType: .danger) { [weak self] in
                self?.suspiciousFiles.append(files[0])
            },
            ScanStep(progress: 61, message: "🔴 HIGH: Persistent ad ID store → \(files[1].name)", logType: .danger) { [weak self] in
                self?.suspiciousFiles.append(files[1])
            },
            ScanStep(progress: 65, message: "🔴 HIGH: Location history outside sandbox → \(files[2].name)", logType: .danger) { [weak self] in
                self?.suspiciousFiles.append(files[2])
            },
            ScanStep(progress: 69, message: "🔴 CRITICAL: Phishing artifact in /tmp → \(files[3].name)", logType: .danger) { [weak self] in
                self?.suspiciousFiles.append(files[3])
            },
            ScanStep(progress: 73, message: "Probing local network topology (192.168.1.0/24)...", logType: .info, action: nil),
            ScanStep(progress: 76, message: "Device found → 192.168.1.1 (Gateway/Router)", logType: .info) { [weak self] in
                self?.networkDevices.append(NetworkDevice(ip: "192.168.1.1", name: "Router", deviceType: "Gateway", openPorts: [80, 443, 8080], risk: .low, manufacturer: "Netgear"))
            },
            ScanStep(progress: 79, message: "⚠ UNKNOWN device → 192.168.1.4 : ports 22, 8888 open", logType: .warning) { [weak self] in
                self?.networkDevices.append(NetworkDevice(ip: "192.168.1.4", name: "Unknown Device", deviceType: "Unidentified", openPorts: [22, 8888], risk: .high, manufacturer: nil))
            },
            ScanStep(progress: 82, message: "Device found → 192.168.1.8 (Smart TV)", logType: .info) { [weak self] in
                self?.networkDevices.append(NetworkDevice(ip: "192.168.1.8", name: "Smart TV", deviceType: "IoT Device", openPorts: [7000, 9080], risk: .medium, manufacturer: "Samsung"))
            },
            ScanStep(progress: 85, message: "Device found → 192.168.1.12 (MacBook Pro)", logType: .info) { [weak self] in
                self?.networkDevices.append(NetworkDevice(ip: "192.168.1.12", name: "MacBook Pro", deviceType: "Computer", openPorts: [5000], risk: .low, manufacturer: "Apple"))
            },
            ScanStep(progress: 89, message: "Cross-referencing domains against threat blocklists...", logType: .system, action: nil),
            ScanStep(progress: 92, message: "Correlating tracker fingerprints (8 SDKs matched)...", logType: .system, action: nil),
            ScanStep(progress: 95, message: "Analyzing data broker connections...", logType: .system, action: nil),
            ScanStep(progress: 98, message: "Building threat map and risk scores...", logType: .system, action: nil),
            ScanStep(progress: 100, message: "✓ Scan complete. Forwarding to SHIELD-AI for analysis...", logType: .success, action: nil),
        ]
    }

    // MARK: - Start Scan
    func startScan() {
        scanTask?.cancel()
        phase = .scanning
        progress = 0
        logs = []
        trackers = []
        suspiciousFiles = []
        networkDevices = []
        aiReport = ""

        let steps = buildSteps()

        scanTask = Task {
            for step in steps {
                guard !Task.isCancelled else { break }

                // Animate progress to step value
                let target = step.progress
                let current = progress
                let increment = (target - current) / 20

                for _ in 0..<20 {
                    guard !Task.isCancelled else { break }
                    progress = min(progress + increment, target)
                    try? await Task.sleep(nanoseconds: 25_000_000) // 25ms
                }
                progress = target

                // Add log
                logs.append(ScanLogEntry(message: step.message, type: step.logType, timestamp: Date()))
                step.action?()

                // Delay between steps
                let delay: UInt64 = step.logType == .danger ? 180_000_000 : 80_000_000
                try? await Task.sleep(nanoseconds: delay)
            }

            guard !Task.isCancelled else { return }
            phase = .done
        }
    }

    // MARK: - Computed Stats
    var criticalCount: Int { suspiciousFiles.filter { $0.severity == .critical }.count + trackers.filter { $0.severity == .critical }.count }
    var highCount: Int { suspiciousFiles.filter { $0.severity == .high }.count + trackers.filter { $0.severity == .high }.count }
    var networkRiskCount: Int { networkDevices.filter { $0.risk == .high || $0.risk == .critical }.count }
    var overallRisk: String {
        if criticalCount > 0 { return "CRITICAL" }
        if highCount > 2 { return "HIGH" }
        if highCount > 0 { return "ELEVATED" }
        return "MODERATE"
    }
    var overallRiskColor: Color {
        if criticalCount > 0 { return .shieldRed }
        if highCount > 2 { return .shieldOrange }
        return .shieldYellow
    }
}
