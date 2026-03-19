import Foundation
import SwiftUI
import Network
import Combine

@MainActor
class NetworkViewModel: ObservableObject {
    @Published var speedResult = SpeedTestResult()
    @Published var isScanning = false

    // MARK: - Speed Test
    func runSpeedTest() async {
        speedResult = SpeedTestResult(status: .running)

        // Ping simulation (real ping via ICMP requires entitlements)
        try? await Task.sleep(nanoseconds: 600_000_000)
        speedResult.ping = Int.random(in: 8...28)

        // Download test (simulated with realistic variance)
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        speedResult.download = Double.random(in: 95...310)

        // Upload test
        try? await Task.sleep(nanoseconds: 900_000_000)
        speedResult.upload = Double.random(in: 35...95)
        speedResult.status = .done
    }

    // MARK: - Network Health
    var networkQuality: String {
        guard let dl = speedResult.download else { return "Unknown" }
        switch dl {
        case 200...: return "Excellent"
        case 100..<200: return "Good"
        case 50..<100: return "Fair"
        default: return "Poor"
        }
    }

    var networkQualityColor: Color {
        guard let dl = speedResult.download else { return .shieldBlue }
        switch dl {
        case 200...: return .shieldGreen
        case 100..<200: return .shieldBlue
        case 50..<100: return .shieldYellow
        default: return .shieldRed
        }
    }
}
