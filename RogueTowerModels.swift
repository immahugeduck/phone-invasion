import Foundation
import SwiftUI
import CoreLocation

// MARK: - Cell Tower Observation
/// A real-time snapshot of the currently connected cell tower
struct CellTowerObservation: Identifiable, Codable {
    let id: UUID
    let timestamp: Date

    // Identity
    let mcc: String           // Mobile Country Code (e.g. "310" = USA)
    let mnc: String           // Mobile Network Code (e.g. "410" = AT&T)
    let cellID: Int           // Unique cell identifier
    let lac: Int              // Location Area Code (2G/3G) or TAC (4G/5G)
    let radioType: RadioType  // Technology generation

    // Signal
    let rssi: Double          // Received Signal Strength Indicator (dBm)
    let rsrp: Double?         // Reference Signal Received Power — 4G/5G (dBm)
    let rsrq: Double?         // Reference Signal Received Quality — 4G/5G (dB)
    let sinr: Double?         // Signal-to-Interference-plus-Noise Ratio (dB)
    let timingAdvance: Int?   // TA value — proxy for physical distance to tower

    // Location context
    let coordinate: CLLocationCoordinate2D?
    let carrierName: String
    let isoCountryCode: String

    // Derived
    var estimatedDistanceMeters: Double? {
        guard let ta = timingAdvance else { return nil }
        // Each TA unit ≈ 78.1 meters (LTE spec)
        return Double(ta) * 78.1
    }

    init(id: UUID = UUID(), timestamp: Date = Date(),
         mcc: String, mnc: String, cellID: Int, lac: Int,
         radioType: RadioType, rssi: Double, rsrp: Double? = nil,
         rsrq: Double? = nil, sinr: Double? = nil, timingAdvance: Int? = nil,
         coordinate: CLLocationCoordinate2D? = nil,
         carrierName: String, isoCountryCode: String) {
        self.id = id; self.timestamp = timestamp
        self.mcc = mcc; self.mnc = mnc; self.cellID = cellID; self.lac = lac
        self.radioType = radioType; self.rssi = rssi; self.rsrp = rsrp
        self.rsrq = rsrq; self.sinr = sinr; self.timingAdvance = timingAdvance
        self.coordinate = coordinate; self.carrierName = carrierName
        self.isoCountryCode = isoCountryCode
    }

    // Codable coordinate shim
    enum CodingKeys: String, CodingKey {
        case id, timestamp, mcc, mnc, cellID, lac, radioType, rssi
        case rsrp, rsrq, sinr, timingAdvance, lat, lng, carrierName, isoCountryCode
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
        mcc = try c.decode(String.self, forKey: .mcc)
        mnc = try c.decode(String.self, forKey: .mnc)
        cellID = try c.decode(Int.self, forKey: .cellID)
        lac = try c.decode(Int.self, forKey: .lac)
        radioType = try c.decode(RadioType.self, forKey: .radioType)
        rssi = try c.decode(Double.self, forKey: .rssi)
        rsrp = try c.decodeIfPresent(Double.self, forKey: .rsrp)
        rsrq = try c.decodeIfPresent(Double.self, forKey: .rsrq)
        sinr = try c.decodeIfPresent(Double.self, forKey: .sinr)
        timingAdvance = try c.decodeIfPresent(Int.self, forKey: .timingAdvance)
        carrierName = try c.decode(String.self, forKey: .carrierName)
        isoCountryCode = try c.decode(String.self, forKey: .isoCountryCode)
        if let lat = try c.decodeIfPresent(Double.self, forKey: .lat),
           let lng = try c.decodeIfPresent(Double.self, forKey: .lng) {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        } else { coordinate = nil }
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id); try c.encode(timestamp, forKey: .timestamp)
        try c.encode(mcc, forKey: .mcc); try c.encode(mnc, forKey: .mnc)
        try c.encode(cellID, forKey: .cellID); try c.encode(lac, forKey: .lac)
        try c.encode(radioType, forKey: .radioType); try c.encode(rssi, forKey: .rssi)
        try c.encodeIfPresent(rsrp, forKey: .rsrp); try c.encodeIfPresent(rsrq, forKey: .rsrq)
        try c.encodeIfPresent(sinr, forKey: .sinr); try c.encodeIfPresent(timingAdvance, forKey: .timingAdvance)
        try c.encode(carrierName, forKey: .carrierName); try c.encode(isoCountryCode, forKey: .isoCountryCode)
        try c.encodeIfPresent(coordinate?.latitude, forKey: .lat)
        try c.encodeIfPresent(coordinate?.longitude, forKey: .lng)
    }
}

// MARK: - Radio Type
enum RadioType: String, Codable, CaseIterable {
    case gsm    = "GSM"
    case cdma   = "CDMA"
    case wcdma  = "WCDMA"
    case lte    = "LTE"
    case nr     = "5G NR"
    case unknown = "Unknown"

    var fingerprintRisk: FingerprintRisk {
        switch self {
        case .gsm:    return .critical  // No encryption by default, trivially fingerprinted
        case .cdma:   return .high
        case .wcdma:  return .medium
        case .lte:    return .medium
        case .nr:     return .low       // 5G NR has better privacy protections
        case .unknown: return .unknown
        }
    }

    var color: Color {
        switch self {
        case .gsm:    return .shieldRed
        case .cdma:   return .shieldOrange
        case .wcdma:  return .shieldYellow
        case .lte:    return .shieldBlue
        case .nr:     return .shieldGreen
        case .unknown: return Color.white.opacity(0.3)
        }
    }

    var generationLabel: String {
        switch self {
        case .gsm: return "2G"; case .cdma: return "2G"
        case .wcdma: return "3G"; case .lte: return "4G"
        case .nr: return "5G"; case .unknown: return "?"
        }
    }
}

// MARK: - Fingerprint Risk Level
enum FingerprintRisk: String, Codable {
    case critical = "CRITICAL"
    case high     = "HIGH"
    case medium   = "MEDIUM"
    case low      = "LOW"
    case unknown  = "UNKNOWN"

    var color: Color {
        switch self {
        case .critical: return .shieldRed
        case .high:     return .shieldOrange
        case .medium:   return .shieldYellow
        case .low:      return .shieldGreen
        case .unknown:  return Color.white.opacity(0.3)
        }
    }
}

// MARK: - Detection Signal
/// A single anomaly signal fired by one detection engine
struct DetectionSignal: Identifiable {
    let id = UUID()
    let type: SignalType
    let severity: SignalSeverity
    let title: String
    let detail: String
    let rawValue: String?       // e.g. "RSSI: -47 dBm"
    let confidence: Double      // 0.0–1.0
    let timestamp: Date

    enum SignalType: String {
        case openCelliD         = "OpenCelliD"
        case signalStrength     = "Signal Anomaly"
        case radioDowngrade     = "Network Downgrade"
        case timingAdvance      = "Timing Advance"
        case encryptionAbsent   = "Encryption Absent"
        case neighborListEmpty  = "Neighbor List Empty"
        case cellIDRotation     = "Cell ID Rotation"
        case lacMismatch        = "LAC/TAC Mismatch"
        case mccMncMismatch     = "MCC/MNC Mismatch"
        case rsrqRsrpRatio      = "RSRP/RSRQ Ratio"
        case bseSignature       = "BSE Signature"
        case mlAnomaly          = "ML Baseline Anomaly"
        case rapidHandoff       = "Rapid Handoff"
        case uplinkPowerReq     = "Uplink Power Request"
    }

    enum SignalSeverity: Int {
        case low = 1, medium = 2, high = 3, critical = 4

        var color: Color {
            switch self {
            case .low:      return .shieldGreen
            case .medium:   return .shieldYellow
            case .high:     return .shieldOrange
            case .critical: return .shieldRed
            }
        }
        var label: String {
            switch self {
            case .low: return "LOW"; case .medium: return "MEDIUM"
            case .high: return "HIGH"; case .critical: return "CRITICAL"
            }
        }
    }

    init(type: SignalType, severity: SignalSeverity, title: String,
         detail: String, rawValue: String? = nil,
         confidence: Double = 0.8, timestamp: Date = Date()) {
        self.type = type; self.severity = severity; self.title = title
        self.detail = detail; self.rawValue = rawValue
        self.confidence = confidence; self.timestamp = timestamp
    }
}

// MARK: - Tower Verdict
struct TowerVerdict {
    let observation: CellTowerObservation
    let signals: [DetectionSignal]
    let riskScore: Int           // 0–100
    let verdict: VerdictType
    let openCelliDMatch: Bool
    let generatedAt: Date

    enum VerdictType: String {
        case legitimate = "LEGITIMATE"
        case suspicious = "SUSPICIOUS"
        case likelyRogue = "LIKELY ROGUE"
        case confirmedRogue = "CONFIRMED ROGUE"

        var color: Color {
            switch self {
            case .legitimate:    return .shieldGreen
            case .suspicious:    return .shieldYellow
            case .likelyRogue:   return .shieldOrange
            case .confirmedRogue: return .shieldRed
            }
        }
        var icon: String {
            switch self {
            case .legitimate:    return "checkmark.shield.fill"
            case .suspicious:    return "exclamationmark.triangle.fill"
            case .likelyRogue:   return "antenna.radiowaves.left.and.right.slash"
            case .confirmedRogue: return "xmark.shield.fill"
            }
        }
    }
}

// MARK: - OpenCelliD Tower Record
struct OpenCelliDRecord: Codable {
    let radio: String
    let mcc: Int
    let mnc: Int
    let lac: Int
    let cellID: Int
    let longitude: Double
    let latitude: Double
    let range: Int          // Estimated coverage radius (meters)
    let samples: Int        // Number of data points
    let averageSignal: Int  // Average RSSI
    let createdAt: Date?
    let updatedAt: Date?
}

// MARK: - Known BSE Signatures
struct BSESignatureDatabase {
    struct Signature {
        let name: String
        let description: String
        let indicators: [SignalIndicator]

        struct SignalIndicator {
            let field: String
            let pattern: String
            let isMandatory: Bool
        }
    }

    /// Known patterns from published research on IMSI catchers and BSE testbeds
    static let signatures: [Signature] = [
        Signature(
            name: "Generic IMSI Catcher",
            description: "Active 2G/3G downgrade attack forcing GSM fallback",
            indicators: [
                .init(field: "radioDowngrade", pattern: "LTE→GSM or WCDMA", isMandatory: true),
                .init(field: "neighborList", pattern: "empty or single entry", isMandatory: true),
                .init(field: "timingAdvance", pattern: "TA=0 (direct proximity)", isMandatory: false),
                .init(field: "rssi", pattern: "> -60 dBm (abnormally strong)", isMandatory: false),
            ]
        ),
        Signature(
            name: "NIST RF Fingerprint Testbed (BSE)",
            description: "Passive fingerprinting infrastructure as described in NIST SP 800-187",
            indicators: [
                .init(field: "radioType", pattern: "LTE or 5G NR (no downgrade needed)", isMandatory: false),
                .init(field: "cellID", pattern: "Not in public tower DB", isMandatory: true),
                .init(field: "rssi", pattern: "Unusually stable, controlled environment", isMandatory: false),
                .init(field: "timingAdvance", pattern: "TA=0–1 (within 1 meter range)", isMandatory: true),
            ]
        ),
        Signature(
            name: "Stingray / Harris IMSI Catcher",
            description: "Law enforcement cell-site simulator, forces 2G fallback",
            indicators: [
                .init(field: "radioDowngrade", pattern: "Forced 2G", isMandatory: true),
                .init(field: "encryption", pattern: "A5/0 (no encryption)", isMandatory: true),
                .init(field: "signalStrength", pattern: "Stronger than surrounding towers", isMandatory: true),
                .init(field: "cellID", pattern: "Absent from OpenCelliD", isMandatory: false),
            ]
        ),
        Signature(
            name: "Passive 5G RF Fingerprinting Node",
            description: "Next-gen passive receiver using 5G NR uplink transmissions",
            indicators: [
                .init(field: "radioType", pattern: "5G NR SA (Standalone)", isMandatory: false),
                .init(field: "cellID", pattern: "Not registered in public database", isMandatory: true),
                .init(field: "neighborList", pattern: "Anomalous neighbor cell configuration", isMandatory: false),
                .init(field: "timingAdvance", pattern: "Very low TA (close proximity receiver)", isMandatory: false),
            ]
        ),
        Signature(
            name: "Commercial SS7 Interception Node",
            description: "Exploits SS7 protocol weaknesses for location and interception",
            indicators: [
                .init(field: "lac", pattern: "LAC not matching carrier's known regional map", isMandatory: true),
                .init(field: "mncMcc", pattern: "Foreign MNC/MCC in domestic territory", isMandatory: false),
                .init(field: "rapidHandoff", pattern: "Repeated tower switches without movement", isMandatory: true),
            ]
        ),
    ]
}

// MARK: - Anomaly Baseline
/// Stores historical tower behavior for on-device ML comparison
struct TowerBaseline: Codable {
    var knownCellIDs: Set<Int>
    var knownLACs: Set<Int>
    var averageRSSI: Double
    var rssiStdDev: Double
    var typicalRadioTypes: [String: Int]   // RadioType.rawValue → count
    var observationCount: Int
    var lastUpdated: Date
    var locationHash: String               // coarse location bucket

    static let empty = TowerBaseline(
        knownCellIDs: [], knownLACs: [],
        averageRSSI: -85.0, rssiStdDev: 12.0,
        typicalRadioTypes: [:], observationCount: 0,
        lastUpdated: Date(), locationHash: ""
    )

    mutating func update(with observation: CellTowerObservation) {
        knownCellIDs.insert(observation.cellID)
        knownLACs.insert(observation.lac)
        let key = observation.radioType.rawValue
        typicalRadioTypes[key, default: 0] += 1
        // Welford's online mean/variance
        observationCount += 1
        let delta = observation.rssi - averageRSSI
        averageRSSI += delta / Double(observationCount)
        let delta2 = observation.rssi - averageRSSI
        let m2 = rssiStdDev * rssiStdDev * Double(observationCount - 1) + delta * delta2
        rssiStdDev = sqrt(m2 / Double(observationCount))
        lastUpdated = Date()
    }
}
