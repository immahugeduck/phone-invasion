import Foundation

@MainActor
final class PrivacyViewModel: ObservableObject {
    @Published var permissions: [PrivacyPermission] = [
        PrivacyPermission(name: "Location", systemImage: "location.fill", enabled: true),
        PrivacyPermission(name: "Camera", systemImage: "camera.fill", enabled: true),
        PrivacyPermission(name: "Microphone", systemImage: "mic.fill", enabled: false),
        PrivacyPermission(name: "Bluetooth", systemImage: "bolt.horizontal.circle.fill", enabled: true)
    ]

    var exposureScore: Int {
        permissions.filter(\.enabled).count * 20
    }

    func toggle(_ permission: PrivacyPermission) {
        guard let index = permissions.firstIndex(where: { $0.id == permission.id }) else { return }
        permissions[index].enabled.toggle()
    }
}
