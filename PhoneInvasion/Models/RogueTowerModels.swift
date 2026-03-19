import Foundation

// MARK: - Rogue Tower

struct RogueTower: Identifiable {
    let id: UUID
    var name: String
    var location: String
    var signalStrength: Int   // dBm
    var frequency: Double      // MHz
    var health: Int            // 0–100 threat score
    var isBlocked: Bool

    init(id: UUID = UUID(), name: String, location: String,
         signalStrength: Int, frequency: Double, health: Int, isBlocked: Bool = false) {
        self.id = id
        self.name = name
        self.location = location
        self.signalStrength = signalStrength
        self.frequency = frequency
        self.health = health
        self.isBlocked = isBlocked
    }

    var threatLevel: ThreatLevel {
        switch health {
        case 75...100: return .critical
        case 50..<75:  return .high
        case 25..<50:  return .medium
        default:        return .low
        }
    }
}

// MARK: - Threat Level

enum ThreatLevel: String, CaseIterable {
    case low      = "Low"
    case medium   = "Medium"
    case high     = "High"
    case critical = "Critical"

    var color: String {
        switch self {
        case .low:      return "green"
        case .medium:   return "yellow"
        case .high:     return "orange"
        case .critical: return "red"
        }
    }
}

// MARK: - Rogue Tower List

struct RogueTowerList {
    var towers: [RogueTower]

    func towerNames() -> [String] {
        towers.map { $0.name }
    }

    func towers(withThreat level: ThreatLevel) -> [RogueTower] {
        towers.filter { $0.threatLevel == level }
    }

    var highestThreat: RogueTower? {
        towers.max(by: { $0.health < $1.health })
    }
}

// MARK: - Scan Result

struct ScanResult {
    var timestamp: Date
    var rogueTowerCount: Int
    var trackerCount: Int
    var suspiciousFileCount: Int
    var rfAnomalyCount: Int

    var totalThreats: Int {
        rogueTowerCount + trackerCount + suspiciousFileCount + rfAnomalyCount
    }

    var summary: String {
        if totalThreats == 0 {
            return "No threats detected."
        }
        var parts: [String] = []
        if rogueTowerCount > 0  { parts.append("\(rogueTowerCount) rogue tower(s)") }
        if trackerCount > 0     { parts.append("\(trackerCount) tracker(s)") }
        if suspiciousFileCount > 0 { parts.append("\(suspiciousFileCount) suspicious file(s)") }
        if rfAnomalyCount > 0   { parts.append("\(rfAnomalyCount) RF anomaly(ies)") }
        return "Detected: " + parts.joined(separator: ", ") + "."
    }
}
