import SwiftUI

struct TrackersView: View {
    @EnvironmentObject var scanVM: ScanViewModel
    @State private var expandedID: UUID?
    @State private var blockedIDs: Set<UUID> = []

    var body: some View {
        VStack(spacing: 0) {
            // Header bar
            HStack {
                Text("\(scanVM.trackers.count) TRACKERS IDENTIFIED")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Spacer()
                if !scanVM.trackers.isEmpty {
                    Text("\(blockedIDs.count) BLOCKED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.shieldGreen)
                        .tracking(1)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if scanVM.trackers.isEmpty {
                EmptyStateView(icon: "antenna.radiowaves.left.and.right",
                               message: "Run a deep scan to detect active trackers")
            } else {
                // Severity breakdown
                SeverityBreakdown(items: scanVM.trackers.map { $0.severity })
                    .padding(.horizontal, 16)
                    .padding(.bottom, 12)

                LazyVStack(spacing: 8) {
                    ForEach(scanVM.trackers.sorted { $0.severity.priority > $1.severity.priority }) { tracker in
                        TrackerCard(
                            tracker: tracker,
                            isExpanded: expandedID == tracker.id,
                            isBlocked: blockedIDs.contains(tracker.id)
                        ) {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                expandedID = expandedID == tracker.id ? nil : tracker.id
                            }
                        } onBlock: {
                            withAnimation {
                                if blockedIDs.contains(tracker.id) {
                                    blockedIDs.remove(tracker.id)
                                } else {
                                    blockedIDs.insert(tracker.id)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.top, 8)
    }
}

// MARK: - Tracker Card
struct TrackerCard: View {
    let tracker: Tracker
    let isExpanded: Bool
    let isBlocked: Bool
    let onTap: () -> Void
    let onBlock: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header row
            Button(action: onTap) {
                HStack(alignment: .top, spacing: 12) {
                    // Severity indicator
                    RoundedRectangle(cornerRadius: 2)
                        .fill(tracker.severity.color)
                        .frame(width: 3, height: 40)

                    VStack(alignment: .leading, spacing: 3) {
                        Text(tracker.name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(isBlocked ? .white.opacity(0.3) : .white)
                        Text(tracker.trackerType)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                            .tracking(0.5)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        SeverityBadge(severity: tracker.severity)
                        if isBlocked {
                            Text("BLOCKED")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.shieldGreen)
                                .tracking(1)
                        }
                    }

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.25))
                }
                .padding(14)
            }
            .buttonStyle(PlainButtonStyle())

            // Expanded detail
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider().background(Color.white.opacity(0.06))

                    // Company
                    DetailRow(label: "COMPANY", value: tracker.company)

                    // Domain
                    DetailRow(label: "DOMAIN", value: tracker.domain)

                    // File path
                    DetailRow(label: "CACHE PATH", value: tracker.filePath)

                    // Data collected
                    VStack(alignment: .leading, spacing: 6) {
                        Text("DATA COLLECTED")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundColor(.shieldBlue)
                            .tracking(1)
                        FlowLayout(items: tracker.dataCollected) { item in
                            Text(item)
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.white.opacity(0.06))
                                .cornerRadius(5)
                        }
                    }

                    // Action buttons
                    HStack(spacing: 8) {
                        Button(action: onBlock) {
                            HStack(spacing: 5) {
                                Image(systemName: isBlocked ? "checkmark.shield.fill" : "shield.slash")
                                    .font(.system(size: 11))
                                Text(isBlocked ? "UNBLOCK" : "BLOCK TRACKER")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                            }
                            .foregroundColor(isBlocked ? .shieldGreen : .shieldRed)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background((isBlocked ? Color.shieldGreen : Color.shieldRed).opacity(0.1))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke((isBlocked ? Color.shieldGreen : Color.shieldRed).opacity(0.3), lineWidth: 1)
                            )
                        }

                        Button {
                            // Navigate to iOS Settings
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "gearshape")
                                    .font(.system(size: 11))
                                Text("SETTINGS")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .tracking(0.5)
                            }
                            .foregroundColor(.shieldBlue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.shieldBlue.opacity(0.08))
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.shieldBlue.opacity(0.2), lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            isBlocked
                ? Color.shieldGreen.opacity(0.04)
                : Color.shieldSurface
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isExpanded ? Color.shieldBlue.opacity(0.2) : Color.shieldBorder, lineWidth: 1)
        )
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                .foregroundColor(.shieldBlue)
                .tracking(1)
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(.white.opacity(0.55))
        }
    }
}

// MARK: - Flow Layout (for tags)
struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        var width: CGFloat = 0
        var rows: [[Item]] = [[]]

        // Simple wrapping approximation
        return VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 5) {
                ForEach(items, id: \.self) { item in
                    content(item)
                }
            }
        }
    }
}

// MARK: - Severity Breakdown Bar
struct SeverityBreakdown: View {
    let items: [Severity]

    var counts: [(Severity, Int)] {
        [.critical, .high, .medium, .low].compactMap { sev in
            let count = items.filter { $0 == sev }.count
            return count > 0 ? (sev, count) : nil
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            ForEach(counts, id: \.0.rawValue) { sev, count in
                HStack(spacing: 5) {
                    Circle().fill(sev.color).frame(width: 6, height: 6)
                    Text("\(count) \(sev.rawValue)")
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(0.5)
                }
            }
            Spacer()
        }
    }
}
