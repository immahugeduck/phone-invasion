import SwiftUI

struct TrackersView: View {
    @State private var trackers: [String] = []
    @State private var isBlockingEnabled: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if trackers.isEmpty {
                    Spacer()
                    Image(systemName: "eye.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("No trackers detected.")
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                } else {
                    List(trackers, id: \.self) { tracker in
                        HStack {
                            Image(systemName: "eye.trianglebadge.exclamationmark")
                                .foregroundColor(.orange)
                            Text(tracker)
                            Spacer()
                            if isBlockingEnabled {
                                Button(action: { blockTracker(tracker) }) {
                                    Text("Block")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Color.red.opacity(0.15))
                                        .foregroundColor(.red)
                                        .cornerRadius(8)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                VStack(spacing: 12) {
                    Toggle("Enable Blocking", isOn: $isBlockingEnabled)
                        .padding(.horizontal, 24)

                    Button(action: detectTrackers) {
                        Label("Scan for Trackers", systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("Tracker Detection")
            .onAppear(perform: detectTrackers)
        }
    }

    func detectTrackers() {
        // Replace with real tracker-detection API in production
        trackers = ["tracker.example.com", "analytics.ad-network.io", "telemetry.vendor.net"]
    }

    func blockTracker(_ tracker: String) {
        print("Blocked tracker: \(tracker)")
        trackers.removeAll { $0 == tracker }
    }
}

struct TrackersView_Previews: PreviewProvider {
    static var previews: some View {
        TrackersView()
    }
}
