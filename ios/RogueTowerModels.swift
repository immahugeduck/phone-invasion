import Foundation

struct RFTower: Identifiable, Codable {
    let id: UUID
    let carrier: String
    let band: String
    let signalStrength: Int
    let status: String

    init(id: UUID = UUID(), carrier: String, band: String, signalStrength: Int, status: String) {
        self.id = id
        self.carrier = carrier
        self.band = band
        self.signalStrength = signalStrength
        self.status = status
    }
}
