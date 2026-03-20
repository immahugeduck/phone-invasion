import Foundation

@MainActor
final class ScanViewModel: ObservableObject {
    @Published var phase: ScanPhase = .idle
    @Published var progress: Double = 0
    @Published var logs: [ScanLogEntry] = []
    @Published var trackers: [Tracker] = []
    @Published var suspiciousFiles: [SuspiciousFile] = []
    @Published var networkDevices: [NetworkDevice] = []
    @Published var rfTowers: [RFTower] = []

    func startScan() {
        phase = .scanning
        progress = 0
        logs = [ScanLogEntry(message: "Initializing scan…")]
        trackers = []
        suspiciousFiles = []
        networkDevices = []
        rfTowers = []

        Task {
            for step in 1...5 {
                try? await Task.sleep(nanoseconds: 250_000_000)
                progress = Double(step) * 20
                logs.append(ScanLogEntry(message: "Completed phase \(step) of 5"))
            }

            trackers = [
                Tracker(name: "Meta SDK", company: "Meta", detail: "Ad attribution and engagement telemetry detected.", severity: .high),
                Tracker(name: "Crash Reporter", company: "Third Party", detail: "Crash analytics framework loaded in app process.", severity: .medium)
            ]

            suspiciousFiles = [
                SuspiciousFile(name: "tracking-cache.db", location: "/Library/Caches", detail: "Persistent cache with identifier-like values.", severity: .medium),
                SuspiciousFile(name: "profile.mobileconfig", location: "/Library/Profiles", detail: "Configuration profile should be reviewed.", severity: .high)
            ]

            networkDevices = [
                NetworkDevice(name: "Router", ipAddress: "192.168.1.1", detail: "Expected gateway.", severity: .low),
                NetworkDevice(name: "Unknown Device", ipAddress: "192.168.1.44", detail: "Unrecognized client observed on LAN.", severity: .high)
            ]

            rfTowers = [
                RFTower(carrier: "Carrier A", band: "LTE B12", signalStrength: -79, status: "Normal"),
                RFTower(carrier: "Carrier A", band: "LTE B66", signalStrength: -52, status: "Review")
            ]

            phase = .complete
            logs.append(ScanLogEntry(message: "Scan complete. Review findings by tab."))
        }
    }

    var riskSummary: String {
        let highest = ([trackers.map(\.severity), suspiciousFiles.map(\.severity), networkDevices.map(\.severity)]
            .flatMap { $0 }
            .sorted { $0.priority > $1.priority }
            .first) ?? .low

        switch highest {
        case .critical: return "Critical"
        case .high: return "High"
        case .medium: return "Moderate"
        case .low: return "Low"
        }
    }
}
