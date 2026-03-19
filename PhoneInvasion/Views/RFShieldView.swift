import SwiftUI

struct RFShieldView: View {
    @State private var isScanning: Bool = false
    @State private var detectedSignals: [RFSignal] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Header status
                HStack {
                    Circle()
                        .fill(isScanning ? Color.green : Color.gray)
                        .frame(width: 10, height: 10)
                    Text(isScanning ? "Scanning for RF Signals…" : "RF Shield Idle")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)

                // Signal list
                if detectedSignals.isEmpty {
                    Spacer()
                    Image(systemName: "waveform.path.ecg.rectangle")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text(isScanning ? "Listening for signals…" : "No signals detected yet.\nTap Start to scan.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                    Spacer()
                } else {
                    List(detectedSignals) { signal in
                        RFSignalRow(signal: signal)
                    }
                }

                // Start / Stop button
                Button(action: toggleScan) {
                    Label(isScanning ? "Stop Scanning" : "Start Scanning",
                          systemImage: isScanning ? "stop.circle.fill" : "play.circle.fill")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isScanning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("RF Shield")
        }
    }

    private func toggleScan() {
        isScanning.toggle()
        if isScanning {
            startDetection()
        } else {
            detectedSignals.removeAll()
        }
    }

    private func startDetection() {
        // Simulate progressive signal discovery
        let samples: [RFSignal] = [
            RFSignal(band: "2.4 GHz", strength: -67, isSuspicious: false),
            RFSignal(band: "5.8 GHz", strength: -54, isSuspicious: false),
            RFSignal(band: "700 MHz", strength: -81, isSuspicious: true),
            RFSignal(band: "1.9 GHz", strength: -72, isSuspicious: false),
        ]
        detectedSignals.removeAll()
        for (i, signal) in samples.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.6) {
                guard isScanning else { return }
                detectedSignals.append(signal)
            }
        }
    }
}

// MARK: - RF Signal Model

struct RFSignal: Identifiable {
    let id: UUID = UUID()
    var band: String
    var strength: Int   // dBm (negative)
    var isSuspicious: Bool

    var strengthLabel: String { "\(strength) dBm" }
}

// MARK: - RF Signal Row

struct RFSignalRow: View {
    let signal: RFSignal

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: signal.isSuspicious ? "exclamationmark.triangle.fill" : "waveform")
                .foregroundColor(signal.isSuspicious ? .orange : .blue)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(signal.band)
                    .fontWeight(.medium)
                if signal.isSuspicious {
                    Text("Suspicious signal detected")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            Spacer()

            Text(signal.strengthLabel)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

struct RFShieldView_Previews: PreviewProvider {
    static var previews: some View {
        RFShieldView()
    }
}
