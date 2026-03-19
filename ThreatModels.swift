import Foundation
import SwiftUI

// MARK: - Severity
enum Severity: String, Codable {
    case critical = "CRITICAL"
    case high     = "HIGH"
    case medium   = "MEDIUM"
    case low      = "LOW"

    var color: Color {
        switch self {
        case .critical: return Color(hex: "#ff2d55")
        case .high:     return Color(hex: "#ff6b35")
        case .medium:   return Color(hex: "#ffd60a")
        case .low:      return Color(hex: "#30d158")
        }
    }

    var backgroundColor: Color { color.opacity(0.12) }

    var priority: Int {
        switch self {
        case .critical: return 4
        case .high:     return 3
        case .medium:   return 2
        case .low:      return 1
        }
    }
}

// MARK: - Tracker Model
struct Tracker: Identifiable, Codable {
    let id: UUID
    let name: String
    let trackerType: String
    let severity: Severity
    let domain: String
    let filePath: String
    let company: String
    let dataCollected: [String]
    let blocked: Bool

    init(id: UUID = UUID(), name: String, trackerType: String, severity: Severity,
         domain: String, filePath: String, company: String, dataCollected: [String], blocked: Bool = false) {
        self.id = id; self.name = name; self.trackerType = trackerType
        self.severity = severity; self.domain = domain; self.filePath = filePath
        self.company = company; self.dataCollected = dataCollected; self.blocked = blocked
    }
}

// MARK: - Suspicious File Model
struct SuspiciousFile: Identifiable, Codable {
    let id: UUID
    let name: String
    let fileType: String
    let severity: Severity
    let size: String
    let path: String
    let description: String
    var quarantined: Bool

    init(id: UUID = UUID(), name: String, fileType: String, severity: Severity,
         size: String, path: String, description: String, quarantined: Bool = false) {
        self.id = id; self.name = name; self.fileType = fileType
        self.severity = severity; self.size = size; self.path = path
        self.description = description; self.quarantined = quarantined
    }
}

// MARK: - Network Device Model
struct NetworkDevice: Identifiable {
    let id: UUID
    let ip: String
    let name: String
    let deviceType: String
    let openPorts: [Int]
    let risk: Severity
    let manufacturer: String?

    init(id: UUID = UUID(), ip: String, name: String, deviceType: String,
         openPorts: [Int], risk: Severity, manufacturer: String? = nil) {
        self.id = id; self.ip = ip; self.name = name; self.deviceType = deviceType
        self.openPorts = openPorts; self.risk = risk; self.manufacturer = manufacturer
    }
}

// MARK: - Speed Test Result
struct SpeedTestResult {
    var ping: Int?
    var download: Double?
    var upload: Double?
    var status: SpeedTestStatus = .idle

    enum SpeedTestStatus { case idle, running, done }
}

// MARK: - Scan Phase
enum ScanPhase { case idle, scanning, done }

// MARK: - Scan Log Entry
struct ScanLogEntry: Identifiable {
    let id = UUID()
    let message: String
    let type: LogType
    let timestamp: Date

    enum LogType { case system, info, warning, danger, success }

    var color: Color {
        switch type {
        case .system:  return Color(hex: "#00c8ff")
        case .info:    return Color.white.opacity(0.35)
        case .warning: return Color(hex: "#ffd60a")
        case .danger:  return Color(hex: "#ff6b35")
        case .success: return Color(hex: "#30d158")
        }
    }
}

// MARK: - Privacy Permission
struct PrivacyPermission: Identifiable {
    let id = UUID()
    let key: String
    let label: String
    let icon: String
    let description: String
    let riskActive: String
    var isEnabled: Bool
}

// MARK: - Tracker Database
struct TrackerDatabase {
    static let all: [Tracker] = [
        Tracker(name: "Meta Pixel SDK", trackerType: "Ad Tracker", severity: .high,
                domain: "connect.facebook.net", filePath: "/Library/Caches/com.facebook.sdk",
                company: "Meta Platforms", dataCollected: ["Device ID", "Behavior", "Location", "Contacts"]),
        Tracker(name: "Google Analytics", trackerType: "Behavioral Tracker", severity: .medium,
                domain: "google-analytics.com", filePath: "/Library/Caches/GAI",
                company: "Alphabet Inc.", dataCollected: ["Session data", "Page views", "Events"]),
        Tracker(name: "Crashlytics", trackerType: "Telemetry", severity: .low,
                domain: "crashlytics.com", filePath: "/Library/Application Support/CrashlyticsCore",
                company: "Google / Firebase", dataCollected: ["Crash reports", "Device model", "OS version"]),
        Tracker(name: "Branch.io", trackerType: "Attribution Tracker", severity: .medium,
                domain: "api.branch.io", filePath: "/Library/Caches/io.branch",
                company: "Branch Metrics", dataCollected: ["Install source", "Deep link clicks", "IDFA"]),
        Tracker(name: "Amplitude SDK", trackerType: "Behavioral Tracker", severity: .medium,
                domain: "api.amplitude.com", filePath: "/Library/Caches/com.amplitude",
                company: "Amplitude Inc.", dataCollected: ["User journeys", "Feature usage", "Retention"]),
        Tracker(name: "AppsFlyer", trackerType: "Ad Attribution", severity: .high,
                domain: "appsflyer.com", filePath: "/Library/Caches/AppsFlyer",
                company: "AppsFlyer Ltd.", dataCollected: ["Ad clicks", "Purchase events", "IDFA", "IP address"]),
        Tracker(name: "TikTok SDK", trackerType: "Cross-App Profiler", severity: .high,
                domain: "analytics.tiktok.com", filePath: "/Library/Caches/com.bytedance",
                company: "ByteDance Ltd.", dataCollected: ["Cross-app behavior", "Location", "Device fingerprint"]),
        Tracker(name: "Mixpanel", trackerType: "Analytics", severity: .low,
                domain: "api.mixpanel.com", filePath: "/Library/Caches/Mixpanel",
                company: "Mixpanel Inc.", dataCollected: ["Product events", "Funnels", "Cohorts"]),
    ]
}

// MARK: - Suspicious Files Database
struct SuspiciousFilesDatabase {
    static let all: [SuspiciousFile] = [
        SuspiciousFile(name: "ProfileService.config", fileType: "MDM Profile", severity: .critical,
                       size: "12 KB", path: "/Library/ConfigurationProfiles/",
                       description: "Possible enterprise/MDM profile installed without explicit user consent. Can grant remote access to your device."),
        SuspiciousFile(name: "adid_cache.db", fileType: "Ad ID Store", severity: .high,
                       size: "48 KB", path: "/Library/Caches/com.apple.adid/",
                       description: "Persistent advertising identifier cache being written by multiple 3rd-party SDKs."),
        SuspiciousFile(name: "location_history.sqlite", fileType: "Location Log", severity: .high,
                       size: "2.1 MB", path: "/Library/Application Support/",
                       description: "SQLite database containing historical GPS coordinates. Found outside normal app sandbox."),
        SuspiciousFile(name: "keychain_dump.plist", fileType: "Phishing Artifact", severity: .critical,
                       size: "88 KB", path: "/tmp/com.sysprefs/",
                       description: "Potential credential harvesting file detected in /tmp. May be associated with a phishing attack vector."),
    ]
}

// MARK: - Color Extension
extension Color {
    static let shieldBackground = Color(hex: "#080c14")
    static let shieldBlue       = Color(hex: "#00c8ff")
    static let shieldGreen      = Color(hex: "#30d158")
    static let shieldRed        = Color(hex: "#ff2d55")
    static let shieldOrange     = Color(hex: "#ff6b35")
    static let shieldYellow     = Color(hex: "#ffd60a")
    static let shieldSurface    = Color.white.opacity(0.04)
    static let shieldBorder     = Color.white.opacity(0.06)

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a,r,g,b) = (255,(int>>8)*17,(int>>4&0xF)*17,(int&0xF)*17)
        case 6: (a,r,g,b) = (255,int>>16,int>>8&0xFF,int&0xFF)
        case 8: (a,r,g,b) = (int>>24,int>>16&0xFF,int>>8&0xFF,int&0xFF)
        default:(a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}
