import Foundation

@MainActor
final class NetworkViewModel: ObservableObject {
    @Published var ping: Int = 0
    @Published var downloadMbps: Int = 0
    @Published var uploadMbps: Int = 0
    @Published var isRunning = false

    func runDemoTest() {
        isRunning = true
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            ping = 18
            try? await Task.sleep(nanoseconds: 300_000_000)
            downloadMbps = 242
            try? await Task.sleep(nanoseconds: 300_000_000)
            uploadMbps = 39
            isRunning = false
        }
    }
}
