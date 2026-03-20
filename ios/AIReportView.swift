import SwiftUI

struct AIReportView: View {
    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    section("Overall Risk", viewModel.riskSummary)
                    section("Trackers", trackerSummary)
                    section("Suspicious Files", fileSummary)
                    section("Network", networkSummary)
                    section("RF", rfSummary)
                }
                .padding()
            }
            .background(Color.shieldBackground)
            .navigationTitle("Report")
        }
    }

    private var trackerSummary: String {
        viewModel.trackers.isEmpty ? "No tracker data yet." : viewModel.trackers.map { "\($0.name): \($0.detail)" }.joined(separator: "\n")
    }

    private var fileSummary: String {
        viewModel.suspiciousFiles.isEmpty ? "No suspicious file data yet." : viewModel.suspiciousFiles.map { "\($0.name): \($0.detail)" }.joined(separator: "\n")
    }

    private var networkSummary: String {
        viewModel.networkDevices.isEmpty ? "No network data yet." : viewModel.networkDevices.map { "\($0.name) (\($0.ipAddress)): \($0.detail)" }.joined(separator: "\n")
    }

    private var rfSummary: String {
        viewModel.rfTowers.isEmpty ? "No RF data yet." : viewModel.rfTowers.map { "\($0.carrier) \($0.band): \($0.status)" }.joined(separator: "\n")
    }

    private func section(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundStyle(.shieldBlue)
            Text(body).frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color.shieldSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
