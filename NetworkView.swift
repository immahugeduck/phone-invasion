import SwiftUI

struct NetworkView: View {
    @EnvironmentObject var scanVM: ScanViewModel
    @StateObject private var networkVM = NetworkViewModel()

    var body: some View {
        VStack(spacing: 12) {
            // Speed Test Card
            SpeedTestCard(vm: networkVM)
                .padding(.horizontal, 16)

            // Network security score
            if !scanVM.networkDevices.isEmpty {
                NetworkSecurityCard(devices: scanVM.networkDevices)
                    .padding(.horizontal, 16)
            }

            // Device list header
            HStack {
                Text("\(scanVM.networkDevices.count) DEVICES ON NETWORK")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            if scanVM.networkDevices.isEmpty {
                EmptyStateView(icon: "wifi", message: "Run a deep scan to map network devices")
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(scanVM.networkDevices.sorted { $0.risk.priority > $1.risk.priority }) { device in
                        NetworkDeviceCard(device: device)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 12)
    }
}

// MARK: - Speed Test Card
struct SpeedTestCard: View {
    @ObservedObject var vm: NetworkViewModel

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                Text("SPEED TEST")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Spacer()
                if vm.speedResult.status == .done {
                    Text(vm.networkQuality)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.networkQualityColor)
                        .tracking(1)
                }
            }

            // Metrics
            HStack(spacing: 0) {
                SpeedMetric(
                    label: "PING",
                    value: vm.speedResult.ping.map { "\($0)" },
                    unit: "ms",
                    color: .shieldGreen,
                    icon: "dot.radiowaves.left.and.right",
                    isRunning: vm.speedResult.status == .running && vm.speedResult.ping == nil
                )
                Divider().background(Color.white.opacity(0.06)).frame(height: 50)
                SpeedMetric(
                    label: "DOWNLOAD",
                    value: vm.speedResult.download.map { String(format: "%.0f", $0) },
                    unit: "Mbps",
                    color: .shieldBlue,
                    icon: "arrow.down.circle",
                    isRunning: vm.speedResult.status == .running && vm.speedResult.download == nil
                )
                Divider().background(Color.white.opacity(0.06)).frame(height: 50)
                SpeedMetric(
                    label: "UPLOAD",
                    value: vm.speedResult.upload.map { String(format: "%.0f", $0) },
                    unit: "Mbps",
                    color: Color(hex: "#bf5af2"),
                    icon: "arrow.up.circle",
                    isRunning: vm.speedResult.status == .running && vm.speedResult.upload == nil
                )
            }

            // Run button
            Button {
                Task { await vm.runSpeedTest() }
            } label: {
                HStack(spacing: 8) {
                    if vm.speedResult.status == .running {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .shieldBlue))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                    }
                    Text(vm.speedResult.status == .running ? "TESTING..." : "RUN SPEED TEST")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(.shieldBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.shieldBlue.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.shieldBlue.opacity(0.2), lineWidth: 1))
            }
            .disabled(vm.speedResult.status == .running)
        }
        .padding(16)
        .background(Color.shieldSurface)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.shieldBorder, lineWidth: 1))
    }
}

// MARK: - Speed Metric
struct SpeedMetric: View {
    let label: String
    let value: String?
    let unit: String
    let color: Color
    let icon: String
    let isRunning: Bool

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(color.opacity(0.7))

            if isRunning {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: color))
                    .scaleEffect(0.6)
                    .frame(height: 22)
            } else {
                Text(value ?? "—")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(value != nil ? color : Color.white.opacity(0.2))
            }

            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.25))
                .tracking(0.8)
            if let _ = value {
                Text(unit)
                    .font(.system(size: 8, design: .monospaced))
                    .foregroundColor(.white.opacity(0.2))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Network Security Card
struct NetworkSecurityCard: View {
    let devices: [NetworkDevice]

    var highRiskCount: Int { devices.filter { $0.risk == .high || $0.risk == .critical }.count }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: highRiskCount > 0 ? "wifi.exclamationmark" : "wifi")
                .font(.system(size: 20))
                .foregroundColor(highRiskCount > 0 ? .shieldOrange : .shieldGreen)

            VStack(alignment: .leading, spacing: 3) {
                Text("NETWORK SECURITY")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Text(highRiskCount > 0 ? "\(highRiskCount) risky device(s) detected on your network" : "Network appears clean")
                    .font(.system(size: 12))
                    .foregroundColor(highRiskCount > 0 ? .shieldOrange : .shieldGreen)
            }
            Spacer()
        }
        .padding(14)
        .background((highRiskCount > 0 ? Color.shieldOrange : Color.shieldGreen).opacity(0.07))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke((highRiskCount > 0 ? Color.shieldOrange : Color.shieldGreen).opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Network Device Card
struct NetworkDeviceCard: View {
    let device: NetworkDevice
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } } label: {
                HStack(spacing: 12) {
                    // Device icon
                    ZStack {
                        Circle()
                            .fill(device.risk.backgroundColor)
                            .frame(width: 38, height: 38)
                        Image(systemName: deviceIcon)
                            .font(.system(size: 15))
                            .foregroundColor(device.risk.color)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(device.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(device.ip) · \(device.deviceType)")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                    }

                    Spacer()
                    SeverityBadge(severity: device.risk)
                }
                .padding(14)
            }
            .buttonStyle(PlainButtonStyle())

            if expanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider().background(Color.white.opacity(0.06))

                    if let mfr = device.manufacturer {
                        DetailRow(label: "MANUFACTURER", value: mfr)
                    }

                    VStack(alignment: .leading, spacing: 5) {
                        Text("OPEN PORTS")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(.shieldBlue)
                            .tracking(1)
                        HStack(spacing: 6) {
                            ForEach(device.openPorts, id: \.self) { port in
                                Text(":\(port)")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(portColor(port))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(portColor(port).opacity(0.1))
                                    .cornerRadius(5)
                            }
                        }
                    }

                    if device.risk == .high || device.risk == .critical {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 10))
                                .foregroundColor(.shieldOrange)
                            Text("This device may be a rogue access point or compromised IoT device.")
                                .font(.system(size: 10))
                                .foregroundColor(.shieldOrange.opacity(0.8))
                        }
                        .padding(10)
                        .background(Color.shieldOrange.opacity(0.08))
                        .cornerRadius(8)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.shieldSurface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(
            expanded ? Color.shieldBlue.opacity(0.2) : Color.shieldBorder, lineWidth: 1))
    }

    var deviceIcon: String {
        switch device.deviceType {
        case "Gateway": return "network"
        case "Computer": return "laptopcomputer"
        case "IoT Device": return "tv"
        case "Unidentified": return "questionmark.circle.fill"
        default: return "desktopcomputer"
        }
    }

    func portColor(_ port: Int) -> Color {
        switch port {
        case 22: return .shieldRed    // SSH
        case 8888: return .shieldOrange // suspicious
        case 80, 443: return .shieldGreen
        default: return .shieldBlue
        }
    }
}
