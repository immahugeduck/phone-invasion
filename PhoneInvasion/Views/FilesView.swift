import SwiftUI

struct FilesView: View {
    @State private var files: [ScannedFile] = ScannedFile.sampleFiles
    @State private var showQuarantinedOnly: Bool = false

    private var displayedFiles: [ScannedFile] {
        showQuarantinedOnly ? files.filter { $0.isQuarantined } : files
    }

    var body: some View {
        NavigationStack {
            List {
                if displayedFiles.isEmpty {
                    Text(showQuarantinedOnly ? "No quarantined files." : "No files found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(displayedFiles) { file in
                        FileRow(file: file) {
                            quarantine(file)
                        }
                    }
                }
            }
            .navigationTitle("Files")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Toggle(isOn: $showQuarantinedOnly) {
                        Label("Quarantined", systemImage: "lock.doc")
                    }
                    .toggleStyle(.button)
                    .tint(showQuarantinedOnly ? .orange : .gray)
                }
            }
        }
    }

    private func quarantine(_ file: ScannedFile) {
        if let idx = files.firstIndex(where: { $0.id == file.id }) {
            files[idx].isQuarantined.toggle()
        }
    }
}

// MARK: - File Row

struct FileRow: View {
    let file: ScannedFile
    let onQuarantine: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: file.isQuarantined ? "lock.doc.fill" : fileIcon(for: file.name))
                .foregroundColor(file.isSuspicious ? .red : (file.isQuarantined ? .orange : .secondary))
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(file.name)
                    .fontWeight(file.isSuspicious ? .semibold : .regular)
                Text(file.path)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if file.isSuspicious && !file.isQuarantined {
                Button(action: onQuarantine) {
                    Text("Quarantine")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.15))
                        .foregroundColor(.red)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            } else if file.isQuarantined {
                Button(action: onQuarantine) {
                    Text("Release")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .foregroundColor(.orange)
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 4)
    }

    private func fileIcon(for name: String) -> String {
        let ext = (name as NSString).pathExtension.lowercased()
        switch ext {
        case "pdf":            return "doc.richtext"
        case "jpg", "png":     return "photo"
        case "mp4", "mov":     return "film"
        case "zip", "tar":     return "archivebox"
        default:               return "doc"
        }
    }
}

// MARK: - Model

struct ScannedFile: Identifiable {
    let id: UUID
    var name: String
    var path: String
    var isQuarantined: Bool
    var isSuspicious: Bool

    init(id: UUID = UUID(), name: String, path: String,
         isQuarantined: Bool = false, isSuspicious: Bool = false) {
        self.id = id
        self.name = name
        self.path = path
        self.isQuarantined = isQuarantined
        self.isSuspicious = isSuspicious
    }

    static let sampleFiles: [ScannedFile] = [
        ScannedFile(name: "notes.txt",      path: "/Documents/notes.txt"),
        ScannedFile(name: "photo.jpg",      path: "/Pictures/photo.jpg"),
        ScannedFile(name: "malware.apk",    path: "/Downloads/malware.apk",  isSuspicious: true),
        ScannedFile(name: "report.pdf",     path: "/Documents/report.pdf"),
        ScannedFile(name: "suspicious.zip", path: "/Downloads/suspicious.zip", isSuspicious: true),
    ]
}

struct FilesView_Previews: PreviewProvider {
    static var previews: some View {
        FilesView()
    }
}
