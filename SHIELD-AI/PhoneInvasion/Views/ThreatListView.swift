// ThreatListView.swift
// Scrollable list of detected threats with blocking controls

import SwiftUI

struct ThreatListView: View {
    @State private var trackers: [String] = []
    @State private var isBlockingEnabled: Bool = false

    var body: some View {
        VStack {
            Text("Tracker Detection and Blocking")
                .font(.largeTitle)
                .padding()

            List(trackers, id: \.self) { tracker in
                HStack {
                    Text(tracker)
                    Spacer()
                    if isBlockingEnabled {
                        Button(action: {
                            blockTracker(tracker)
                        }) {
                            Text("Block")
                                .foregroundColor(.red)
                        }
                    }
                }
            }

            Toggle("Enable Blocking", isOn: $isBlockingEnabled)
                .padding()

            Spacer()
        }
        .onAppear(perform: detectTrackers)
    }

    func detectTrackers() {
        // Sample trackers detection logic
        trackers = ["Tracker1.com", "Tracker2.com", "Tracker3.com"]
    }

    func blockTracker(_ tracker: String) {
        // Logic to block the tracker
        print("Blocked tracker: \(tracker)")
        if let index = trackers.firstIndex(of: tracker) {
            trackers.remove(at: index)
        }
    }
}

struct ThreatListView_Previews: PreviewProvider {
    static var previews: some View {
        ThreatListView()
    }
}
