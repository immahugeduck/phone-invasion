import SwiftUI

struct NetworkView: View {
    @State private var isConnected: Bool = false
    @State private var connectionType: String = "Unknown"
    @State private var isChecking: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Status icon
                Image(systemName: isConnected ? "wifi" : "wifi.slash")
                    .font(.system(size: 64))
                    .foregroundColor(isConnected ? .green : .red)
                    .padding(.top, 40)

                // Status text
                VStack(spacing: 8) {
                    Text(isConnected ? "Connected" : "Not Connected")
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(isConnected ? .green : .red)

                    if isConnected {
                        Label(connectionType, systemImage: connectionTypeIcon)
                            .foregroundColor(.secondary)
                    }
                }

                Divider()
                    .padding(.horizontal, 40)

                // Details list
                if isConnected {
                    VStack(alignment: .leading, spacing: 12) {
                        NetworkDetailRow(label: "Type", value: connectionType)
                        NetworkDetailRow(label: "Status", value: "Active")
                        NetworkDetailRow(label: "Security", value: connectionSecurityLabel)
                    }
                    .padding(.horizontal, 24)
                }

                Spacer()

                // Check button
                Button(action: checkNetworkStatus) {
                    Label(isChecking ? "Checking…" : "Check Network",
                          systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                }
                .disabled(isChecking)
                .padding(.bottom, 32)
            }
            .navigationTitle("Network Status")
            .onAppear { checkNetworkStatus() }
        }
    }

    // MARK: - Helpers

    private var connectionTypeIcon: String {
        switch connectionType {
        case "WiFi":     return "wifi"
        case "Cellular": return "cellularbars"
        default:         return "network"
        }
    }

    private var connectionSecurityLabel: String {
        switch connectionType {
        case "WiFi":     return "WPA2/WPA3"
        case "Cellular": return "LTE / 5G"
        default:         return "Unknown"
        }
    }

    func checkNetworkStatus() {
        isChecking = true
        // Replace with actual NWPathMonitor-based check in production
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isConnected = true
            connectionType = "WiFi"
            isChecking = false
        }
    }
}

// MARK: - Network Detail Row

struct NetworkDetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct NetworkView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkView()
    }
}
