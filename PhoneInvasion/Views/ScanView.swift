import SwiftUI

struct ScanView: View {
    @State private var isScanning: Bool = false
    @State private var scanProgress: Double = 0.0
    @State private var lastResult: ScanResult? = nil
    @State private var pulseAnimation: Bool = false

    private let detector = RogueTowerDetector()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Scan Orb
                    ZStack {
                        Circle()
                            .stroke(orbColor.opacity(0.3), lineWidth: 16)
                            .frame(width: 180, height: 180)
                            .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                            .animation(
                                isScanning
                                    ? Animation.easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                    : .default,
                                value: pulseAnimation
                            )

                        Circle()
                            .fill(orbColor.opacity(0.15))
                            .frame(width: 180, height: 180)

                        VStack(spacing: 6) {
                            Image(systemName: isScanning ? "waveform" : "antenna.radiowaves.left.and.right")
                                .font(.system(size: 44))
                                .foregroundColor(orbColor)
                            Text(isScanning ? "Scanning…" : "Tap to Scan")
                                .font(.headline)
                                .foregroundColor(orbColor)
                        }
                    }
                    .padding(.top, 32)
                    .onTapGesture { startScan() }

                    // Progress bar (visible while scanning)
                    if isScanning {
                        ProgressView(value: scanProgress)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .padding(.horizontal, 40)
                    }

                    // Scan button
                    Button(action: startScan) {
                        Label(isScanning ? "Scanning…" : "Start Scan",
                              systemImage: isScanning ? "stop.circle" : "play.circle.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isScanning ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 40)
                    }
                    .disabled(isScanning)

                    // Threat summary
                    if let result = lastResult {
                        ThreatSummaryCard(result: result)
                            .padding(.horizontal, 16)
                    } else if !isScanning {
                        Text("Run a scan to check for threats.")
                            .foregroundColor(.secondary)
                            .padding()
                    }

                    Spacer(minLength: 20)
                }
            }
            .navigationTitle("Phone Invasion")
        }
    }

    // MARK: - Helpers

    private var orbColor: Color {
        guard let result = lastResult else { return .blue }
        if result.totalThreats == 0 { return .green }
        if result.totalThreats < 3  { return .yellow }
        return .red
    }

    private func startScan() {
        guard !isScanning else { return }
        isScanning = true
        pulseAnimation = true
        scanProgress = 0.0

        // Simulate a timed scan
        let steps = 20
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.15) {
                scanProgress = Double(i) / Double(steps)
                if i == steps {
                    finishScan()
                }
            }
        }
    }

    private func finishScan() {
        lastResult = detector.runScan()
        isScanning = false
        pulseAnimation = false
    }
}

// MARK: - Threat Summary Card

struct ThreatSummaryCard: View {
    let result: ScanResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: result.totalThreats == 0 ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                    .foregroundColor(result.totalThreats == 0 ? .green : .red)
                    .font(.title2)
                Text(result.totalThreats == 0 ? "All Clear" : "\(result.totalThreats) Threat(s) Found")
                    .font(.headline)
                    .foregroundColor(result.totalThreats == 0 ? .green : .red)
            }

            Divider()

            ThreatRow(icon: "antenna.radiowaves.left.and.right", label: "Rogue Towers",
                      count: result.rogueTowerCount)
            ThreatRow(icon: "eye.slash", label: "Trackers",
                      count: result.trackerCount)
            ThreatRow(icon: "folder.badge.questionmark", label: "Suspicious Files",
                      count: result.suspiciousFileCount)
            ThreatRow(icon: "waveform.path.ecg.rectangle", label: "RF Anomalies",
                      count: result.rfAnomalyCount)

            Text(result.summary)
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top, 4)

            Text("Scanned at \(result.timestamp, style: .time)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
    }
}

struct ThreatRow: View {
    let icon: String
    let label: String
    let count: Int

    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(count > 0 ? .orange : .secondary)
            Text(label)
                .foregroundColor(.primary)
            Spacer()
            Text("\(count)")
                .fontWeight(count > 0 ? .bold : .regular)
                .foregroundColor(count > 0 ? .orange : .secondary)
        }
    }
}

struct ScanView_Previews: PreviewProvider {
    static var previews: some View {
        ScanView()
    }
}
