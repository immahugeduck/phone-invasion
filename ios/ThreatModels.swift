import Foundation

enum Severity: String, CaseIterable, Codable {
    case low = "LOW"
    case medium = "MEDIUM"
    case high = "HIGH"
    case critical = "CRITICAL"

    var priority: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .critical: return 4
        }
    }
}

struct Tracker: Identifiable, Codable {
    let id: UUID
    let name: String
    let company: String
    let detail: String
    let severity: Severity

    init(id: UUID = UUID(), name: String, company: String, detail: String, severity: Severity) {
        self.id = id
        self.name = name
        self.company = company
        self.detail = detail
        self.severity = severity
    }
}

struct SuspiciousFile: Identifiable, Codable {
    let id: UUID
    let name: String
    let location: String
    let detail: String
    let severity: Severity

    init(id: UUID = UUID(), name: String, location: String, detail: String, severity: Severity) {
        self.id = id
        self.name = name
        self.location = location
        self.detail = detail
        self.severity = severity
    }
}

struct NetworkDevice: Identifiable, Codable {
    let id: UUID
    let name: String
    let ipAddress: String
    let detail: String
    let severity: Severity

    init(id: UUID = UUID(), name: String, ipAddress: String, detail: String, severity: Severity) {
        self.id = id
        self.name = name
        self.ipAddress = ipAddress
        self.detail = detail
        self.severity = severity
    }
}

enum ScanPhase {
    case idle
    case scanning
    case complete
}

struct ScanLogEntry: Identifiable {
    let id = UUID()
    let message: String
}

struct PrivacyPermission: Identifiable {
    let id = UUID()
    let name: String
    let systemImage: String
    var enabled: Bool
}

enum AppTab: String, CaseIterable, Identifiable {
    case scan = "Scan"
    case trackers = "Trackers"
    case files = "Files"
    case network = "Network"
    case privacy = "Privacy"
    case rf = "RF"
    case report = "Report"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .scan: return "shield.lefthalf.filled"
        case .trackers: return "eye.trianglebadge.exclamationmark"
        case .files: return "doc.text.magnifyingglass"
        case .network: return "wifi"
        case .privacy: return "lock.shield"
        case .rf: return "antenna.radiowaves.left.and.right"
        case .report: return "doc.richtext"
        }
    }
}
