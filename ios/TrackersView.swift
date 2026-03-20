import SwiftUI

struct TrackersView: View {
    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.trackers.sorted { $0.severity.priority > $1.severity.priority }) { tracker in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tracker.name).font(.headline)
                        Spacer()
                        Text(tracker.severity.rawValue).foregroundStyle(.shieldBlue)
                    }
                    Text(tracker.company).foregroundStyle(.secondary)
                    Text(tracker.detail).font(.subheadline)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.shieldSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.shieldBackground)
            .navigationTitle("Trackers")
        }
    }
}
