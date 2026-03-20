import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .scan

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView()
                .tabItem { Label(AppTab.scan.rawValue, systemImage: AppTab.scan.icon) }
                .tag(AppTab.scan)

            TrackersView()
                .tabItem { Label(AppTab.trackers.rawValue, systemImage: AppTab.trackers.icon) }
                .tag(AppTab.trackers)

            FilesView()
                .tabItem { Label(AppTab.files.rawValue, systemImage: AppTab.files.icon) }
                .tag(AppTab.files)

            NetworkView()
                .tabItem { Label(AppTab.network.rawValue, systemImage: AppTab.network.icon) }
                .tag(AppTab.network)

            PrivacyView()
                .tabItem { Label(AppTab.privacy.rawValue, systemImage: AppTab.privacy.icon) }
                .tag(AppTab.privacy)

            RFShieldView()
                .tabItem { Label(AppTab.rf.rawValue, systemImage: AppTab.rf.icon) }
                .tag(AppTab.rf)

            AIReportView()
                .tabItem { Label(AppTab.report.rawValue, systemImage: AppTab.report.icon) }
                .tag(AppTab.report)
        }
        .tint(.shieldBlue)
        .background(Color.shieldBackground.ignoresSafeArea())
    }
}
