import SwiftUI

struct NetworkView: View {
    @EnvironmentObject private var scanViewModel: ScanViewModel
    @StateObject private var networkViewModel = NetworkViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Speed Check").font(.headline)
                        HStack {
                            metric("Ping", "\(networkViewModel.ping) ms")
                            metric("Down", "\(networkViewModel.downloadMbps) Mbps")
                            metric("Up", "\(networkViewModel.uploadMbps) Mbps")
                        }
                        Button("Run Demo Test") {
                            networkViewModel.runDemoTest()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.shieldBlue)
                    }
                    .padding()
                    .background(Color.shieldSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    ForEach(scanViewModel.networkDevices.sorted { $0.severity.priority > $1.severity.priority }) { device in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(device.name).font(.headline)
                                Spacer()
                                Text(device.ipAddress).foregroundStyle(.secondary)
                            }
                            Text(device.detail)
                            Text(device.severity.rawValue).font(.caption).foregroundStyle(.shieldYellow)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.shieldSurface)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding()
            }
            .background(Color.shieldBackground)
            .navigationTitle("Network")
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
