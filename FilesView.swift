import SwiftUI

struct FilesView: View {
    @EnvironmentObject var scanVM: ScanViewModel
    @State private var expandedID: UUID?
    @State private var quarantinedIDs: Set<UUID> = []
    @State private var deletedIDs: Set<UUID> = []
    @State private var showDeleteAlert = false
    @State private var pendingDeleteID: UUID?

    var visibleFiles: [SuspiciousFile] {
        scanVM.suspiciousFiles.filter { !deletedIDs.contains($0.id) }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("\(visibleFiles.count) SUSPICIOUS FILES")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Spacer()
                if !quarantinedIDs.isEmpty {
                    Text("\(quarantinedIDs.count) QUARANTINED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.shieldYellow)
                        .tracking(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if scanVM.suspiciousFiles.isEmpty {
                EmptyStateView(icon: "doc.badge.exclamationmark",
                               message: "Run a deep scan to detect suspicious files")
            } else {
                // Storage impact bar
                StorageImpactView(files: scanVM.suspiciousFiles)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)

                LazyVStack(spacing: 8) {
                    ForEach(visibleFiles.sorted { $0.severity.priority > $1.severity.priority }) { file in
                        FileCard(
                            file: file,
                            isExpanded: expandedID == file.id,
                            isQuarantined: quarantinedIDs.contains(file.id)
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                expandedID = expandedID == file.id ? nil : file.id
                            }
                        } onQuarantine: {
                            withAnimation {
                                if quarantinedIDs.contains(file.id) {
                                    quarantinedIDs.remove(file.id)
                                } else {
                                    quarantinedIDs.insert(file.id)
                                }
                            }
                        } onDelete: {
                            pendingDeleteID = file.id
                            showDeleteAlert = true
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
        .alert("Delete File", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                if let id = pendingDeleteID {
                    withAnimation { deletedIDs.insert(id) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently remove the file from your device.")
        }
    }
}

// MARK: - File Card
struct FileCard: View {
    let file: SuspiciousFile
    let isExpanded: Bool
    let isQuarantined: Bool
    let onTap: () -> Void
    let onQuarantine: () -> Void
    let onDelete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(alignment: .center, spacing: 12) {
                    // File type icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(file.severity.backgroundColor)
                            .frame(width: 40, height: 40)
                        Image(systemName: fileIcon)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(file.severity.color)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(file.name)
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                        HStack(spacing: 8) {
                            Text(file.fileType)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                            Text("·")
                                .foregroundColor(.white.opacity(0.2))
                            Text(file.size)
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        SeverityBadge(severity: file.severity)
                        if isQuarantined {
                            Text("QUARANTINED")
                                .font(.system(size: 7, weight: .bold, design: .monospaced))
                                .foregroundColor(.shieldYellow)
                                .tracking(0.5)
                        }
                    }
                }
                .padding(14)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.white.opacity(0.06))

                    DetailRow(label: "FILE PATH", value: file.path + file.name)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("THREAT ANALYSIS")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(.shieldBlue)
                            .tracking(1)
                        Text(file.description)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.55))
                            .lineSpacing(4)
                    }

                    HStack(spacing: 8) {
                        Button(action: onQuarantine) {
                            HStack(spacing: 5) {
                                Image(systemName: isQuarantined ? "lock.open" : "lock.fill")
                                    .font(.system(size: 11))
                                Text(isQuarantined ? "UNQUARANTINE" : "QUARANTINE")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.shieldYellow)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.shieldYellow.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.shieldYellow.opacity(0.3), lineWidth: 1))
                        }

                        Button(action: onDelete) {
                            HStack(spacing: 5) {
                                Image(systemName: "trash")
                                    .font(.system(size: 11))
                                Text("DELETE")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.shieldRed)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Color.shieldRed.opacity(0.1))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.shieldRed.opacity(0.3), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(isQuarantined ? Color.shieldYellow.opacity(0.04) : Color.shieldSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isExpanded ? Color.shieldBlue.opacity(0.2) : Color.shieldBorder, lineWidth: 1)
        )
    }

    var fileIcon: String {
        switch file.fileType {
        case "MDM Profile": return "person.badge.shield.checkmark"
        case "Ad ID Store": return "eye.fill"
        case "Location Log": return "location.fill"
        case "Phishing Artifact": return "exclamationmark.triangle.fill"
        default: return "doc.fill"
        }
    }
}

// MARK: - Storage Impact View
struct StorageImpactView: View {
    let files: [SuspiciousFile]

    var totalSizeLabel: String {
        "~\(files.count * 12 + 88) KB suspicious data"
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "internaldrive")
                .font(.system(size: 14))
                .foregroundColor(.shieldOrange)
            VStack(alignment: .leading, spacing: 2) {
                Text("STORAGE IMPACT")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Text(totalSizeLabel)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.shieldOrange)
            }
            Spacer()
        }
        .padding(12)
        .background(Color.shieldOrange.opacity(0.06))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.shieldOrange.opacity(0.15), lineWidth: 1))
    }
}
