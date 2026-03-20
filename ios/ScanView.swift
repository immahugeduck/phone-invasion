import SwiftUI

struct ScanView: View {
    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    summaryCard

                    Button(action: viewModel.startScan) {
                        Label(viewModel.phase == .scanning ? "Scanning…" : "Run Deep Scan", systemImage: "play.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.shieldBlue)
                    .disabled(viewModel.phase == .scanning)

                    if viewModel.phase != .idle {
                        ProgressView(value: viewModel.progress, total: 100)
                            .tint(.shieldBlue)
                        Text("Progress: \(Int(viewModel.progress))%")
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scan Log")
                            .font(.headline)
                        ForEach(viewModel.logs) { entry in
                            Text("• \(entry.message)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Phone Invasion")
            .background(Color.shieldBackground)
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Risk Summary")
                .font(.headline)
            Text(viewModel.riskSummary)
                .font(.largeTitle.bold())
                .foregroundStyle(.shieldBlue)
            Text("Use the scan to populate trackers, files, network devices, and RF observations.")
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.shieldSurface)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.shieldBorder))
    }
}
