import Foundation

// This file implements privacy kill switches and exposure scoring features.

struct PrivacyKillSwitches {
    var switches: [String: Bool] = [:]

    mutating func setSwitch(name: String, enabled: Bool) {
        switches[name] = enabled
    }

    func isSwitchEnabled(name: String) -> Bool {
        return switches[name] ?? false
    }
}

struct ExposureScoring {
    var score: Int = 0

    mutating func updateScore(forActivity activity: String) {
        // Example scoring logic based on activity
        switch activity {
        case "tracking":
            score += 5
        case "data-sharing":
            score += 10
        default:
            score += 1
        }
    }
}

// Example usage:
var killSwitches = PrivacyKillSwitches()
killSwitches.setSwitch(name: "locationTracking", enabled: false)

var exposureScoring = ExposureScoring()
exposureScoring.updateScore(forActivity: "tracking")
print("Exposure Score: \(exposureScoring.score)")