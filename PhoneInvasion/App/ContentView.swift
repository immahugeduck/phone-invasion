import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "antenna.radiowaves.left.and.right")
                }

            NetworkView()
                .tabItem {
                    Label("Network", systemImage: "network")
                }

            TrackersView()
                .tabItem {
                    Label("Trackers", systemImage: "eye.slash")
                }

            FilesView()
                .tabItem {
                    Label("Files", systemImage: "folder.badge.questionmark")
                }

            RFShieldView()
                .tabItem {
                    Label("RF Shield", systemImage: "waveform.path.ecg.rectangle")
                }

            PrivacyView()
                .tabItem {
                    Label("Privacy", systemImage: "lock.shield")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
