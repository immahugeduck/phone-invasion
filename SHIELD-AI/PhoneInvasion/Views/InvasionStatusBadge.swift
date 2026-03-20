// InvasionStatusBadge.swift
// Reusable status indicator component for RF shield and rogue tower detection

import SwiftUI

struct InvasionStatusBadge: View {
    @State private var detectedSignals: [String] = []
    @State private var isScanning: Bool = false

    var body: some View {
        VStack {
            Text("RF Shield for Rogue Tower Detection")
                .font(.title)
                .padding()

            List(detectedSignals, id: \.self) { signal in
                Text(signal)
            }
            .onAppear(perform: startScanning)

            Button(action: toggleScanning) {
                Text(isScanning ? "Stop Scanning" : "Start Scanning")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }

    private func startScanning() {
        isScanning = true
        // Simulate signal detection
        detectedSignals = ["Signal 1: 2.4 GHz", "Signal 2: 5.8 GHz"]
    }

    private func toggleScanning() {
        isScanning.toggle()
        if isScanning {
            startScanning()
        } else {
            detectedSignals.removeAll()
        }
    }
}

struct InvasionStatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        InvasionStatusBadge()
    }
}
