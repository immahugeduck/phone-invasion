import SwiftUI

@main
struct ShieldAIApp: App {
    @StateObject private var scanViewModel = ScanViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanViewModel)
                .preferredColorScheme(.dark)
        }
    }
}
