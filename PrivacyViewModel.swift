import Foundation
import SwiftUI
import CoreLocation
import AVFoundation
import Combine

@MainActor
class PrivacyViewModel: ObservableObject {
    @Published var permissions: [PrivacyPermission] = [
        PrivacyPermission(key: "location", label: "Location Services", icon: "location.fill",
                          description: "GPS & background location access",
                          riskActive: "3 apps tracking your location continuously",
                          isEnabled: true),
        PrivacyPermission(key: "camera", label: "Camera Access", icon: "camera.fill",
                          description: "Front & rear camera permissions",
                          riskActive: "2 apps with persistent camera access",
                          isEnabled: true),
        PrivacyPermission(key: "microphone", label: "Microphone", icon: "mic.fill",
                          description: "Audio capture permissions",
                          riskActive: "Currently disabled — no risk detected",
                          isEnabled: false),
        PrivacyPermission(key: "bluetooth", label: "Bluetooth", icon: "bluetooth",
                          description: "Proximity & device tracking via BT",
                          riskActive: "Bluetooth used for cross-device tracking",
                          isEnabled: true),
        PrivacyPermission(key: "contacts", label: "Contacts", icon: "person.2.fill",
                          description: "Access to your contacts list",
                          riskActive: "Meta SDK reading contact hashes for ad targeting",
                          isEnabled: false),
    ]

    @Published var locationAuthStatus: CLAuthorizationStatus = .notDetermined
    @Published var cameraAuthStatus: AVAuthorizationStatus = .notDetermined
    @Published var micAuthStatus: AVAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()

    init() { checkStatuses() }

    func checkStatuses() {
        locationAuthStatus = locationManager.authorizationStatus
        cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        micAuthStatus = AVCaptureDevice.authorizationStatus(for: .audio)
    }

    func togglePermission(_ key: String) {
        guard let idx = permissions.firstIndex(where: { $0.key == key }) else { return }
        permissions[idx].isEnabled.toggle()

        // For real kill switch, open Settings
        switch key {
        case "location":
            openSettings()
        case "camera":
            openSettings()
        case "microphone":
            openSettings()
        default: break
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            // Only open settings when toggling real permissions
            // UIApplication.shared.open(url)
        }
    }

    var exposureScore: Int {
        let enabledCount = permissions.filter { $0.isEnabled }.count
        switch enabledCount {
        case 0: return 8
        case 1: return 32
        case 2: return 56
        case 3: return 74
        case 4: return 87
        default: return 95
        }
    }

    var exposureLabel: String {
        switch exposureScore {
        case 0..<30: return "LOW EXPOSURE"
        case 30..<60: return "MODERATE"
        case 60..<80: return "HIGH EXPOSURE"
        default: return "CRITICAL EXPOSURE"
        }
    }

    var exposureColor: Color {
        switch exposureScore {
        case 0..<30: return .shieldGreen
        case 30..<60: return .shieldYellow
        case 60..<80: return .shieldOrange
        default: return .shieldRed
        }
    }
}
