// ThreatDetailView.swift
// Expanded threat info and action steps for a selected threat

import SwiftUI

struct ThreatDetailView: View {
    @State private var files: [String] = []
    @State private var quarantinedFiles: [String] = []
    @State private var isQuarantineActive: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(files, id: \.self) { file in
                    HStack {
                        Text(file)
                        Spacer()
                        if isSuspicious(file: file) {
                            Button(action: {
                                quarantineFile(file)
                            }) {
                                Text("Quarantine").foregroundColor(.red)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Files")
            .toolbar {
                Button(action: toggleQuarantine) {
                    Text(isQuarantineActive ? "Show All" : "Show Quarantined")
                }
            }
        }
    }

    private func isSuspicious(file: String) -> Bool {
        // Implement your logic to determine if a file is suspicious
        return false
    }

    private func quarantineFile(_ file: String) {
        quarantinedFiles.append(file)
        // Implement additional logic for quarantining the file
    }

    private func toggleQuarantine() {
        isQuarantineActive.toggle()
        // Logic to filter files based on quarantine status
    }
}

struct ThreatDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ThreatDetailView()
    }
}
