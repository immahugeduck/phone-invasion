import SwiftUI

struct FilesView: View {
    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.suspiciousFiles.sorted { $0.severity.priority > $1.severity.priority }) { file in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(file.name).font(.headline)
                        Spacer()
                        Text(file.severity.rawValue).foregroundStyle(.shieldOrange)
                    }
                    Text(file.location).font(.caption).foregroundStyle(.secondary)
                    Text(file.detail).font(.subheadline)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.shieldSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.shieldBackground)
            .navigationTitle("Files")
        }
    }
}
