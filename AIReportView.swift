import SwiftUI

struct AIReportView: View {
    @EnvironmentObject var scanVM: ScanViewModel
    @StateObject private var privacyVM = PrivacyViewModel()
    @State private var report: String = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var hasGenerated = false

    var body: some View {
        VStack(spacing: 12) {
            // SHIELD-AI header
            AIHeader()
                .padding(.horizontal, 16)

            if scanVM.phase == .idle {
                EmptyStateView(icon: "brain", message: "Run a deep scan first — SHIELD-AI needs data to analyze")
                    .padding(.top, 20)

            } else if isLoading {
                AILoadingView()
                    .padding(.top, 20)

            } else if let err = error {
                AIErrorView(message: err) {
                    Task { await generateReport() }
                }
                .padding(.horizontal, 16)

            } else if report.isEmpty {
                // Auto-generate on appear
                Color.clear.onAppear {
                    if !hasGenerated {
                        Task { await generateReport() }
                    }
                }

            } else {
                // Report content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ReportContent(text: report)
                            .padding(.horizontal, 16)

                        // Regenerate button
                        Button {
                            Task { await generateReport() }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.clockwise")
                                    .font(.system(size: 12))
                                Text("REGENERATE REPORT")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .tracking(1)
                            }
                            .foregroundColor(.shieldBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 42)
                            .background(Color.shieldBlue.opacity(0.08))
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.shieldBlue.opacity(0.15), lineWidth: 1))
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    }
                }
            }
        }
        .padding(.top, 12)
    }

    func generateReport() async {
        isLoading = true
        error = nil
        hasGenerated = true

        do {
            report = try await AIService.shared.generateThreatReport(
                trackers: scanVM.trackers,
                files: scanVM.suspiciousFiles,
                networkDevices: scanVM.networkDevices,
                privacyPermissions: privacyVM.permissions
            )
        } catch {
            self.error = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - AI Header
struct AIHeader: View {
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.shieldBlue.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: "brain")
                    .font(.system(size: 20))
                    .foregroundColor(.shieldBlue)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text("SHIELD-AI THREAT INTELLIGENCE")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.shieldBlue)
                    .tracking(0.5)
                Text("Powered by Claude · Anthropic")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.3))
            }

            Spacer()

            // Live indicator
            HStack(spacing: 4) {
                Circle()
                    .fill(Color.shieldGreen)
                    .frame(width: 6, height: 6)
                    .modifier(PulseModifier())
                Text("LIVE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.shieldGreen)
                    .tracking(1)
            }
        }
        .padding(14)
        .background(Color.shieldBlue.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.shieldBlue.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Loading View
struct AILoadingView: View {
    @State private var dots = ""
    @State private var currentStep = 0
    let steps = [
        "Correlating 8 trackers × threat database",
        "Mapping data broker relationships",
        "Analyzing hardware load signature",
        "Building threat intelligence report",
        "Finalizing AI trace summary"
    ]

    var body: some View {
        VStack(spacing: 20) {
            // Animated brain icon
            ZStack {
                Circle()
                    .fill(Color.shieldBlue.opacity(0.08))
                    .frame(width: 80, height: 80)
                Image(systemName: "brain")
                    .font(.system(size: 34))
                    .foregroundColor(.shieldBlue)
                    .symbolEffect(.pulse)
            }

            VStack(spacing: 8) {
                Text("SHIELD-AI ANALYZING\(dots)")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.shieldBlue)
                    .tracking(1)
                Text(steps[currentStep])
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .padding(30)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
                dots = dots.count < 3 ? dots + "." : ""
            }
            Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { _ in
                withAnimation { currentStep = (currentStep + 1) % steps.count }
            }
        }
    }
}

// MARK: - Error View
struct AIErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 30))
                .foregroundColor(.shieldOrange)

            Text("AI ENGINE OFFLINE")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(.shieldOrange)
                .tracking(1)

            Text(message)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Text("Add your Anthropic API key to AIService.swift to enable AI reports")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.25))
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Text("RETRY")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(.shieldBlue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.shieldBlue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding(24)
        .background(Color.shieldOrange.opacity(0.05))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.shieldOrange.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - Report Content Renderer
struct ReportContent: View {
    let text: String

    var sections: [(title: String, body: String)] {
        var result: [(String, String)] = []
        let lines = text.components(separatedBy: "\n")
        var currentTitle = ""
        var currentBody: [String] = []

        for line in lines {
            if line.hasPrefix("## ") {
                if !currentTitle.isEmpty {
                    result.append((currentTitle, currentBody.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)))
                }
                currentTitle = String(line.dropFirst(3))
                currentBody = []
            } else {
                currentBody.append(line)
            }
        }
        if !currentTitle.isEmpty {
            result.append((currentTitle, currentBody.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)))
        }

        // Fallback: no sections found
        if result.isEmpty {
            return [("THREAT REPORT", text)]
        }
        return result
    }

    var body: some View {
        VStack(spacing: 10) {
            ForEach(Array(sections.enumerated()), id: \.offset) { _, section in
                ReportSection(title: section.title, body: section.body)
            }
        }
    }
}

// MARK: - Report Section Card
struct ReportSection: View {
    let title: String
    let body: String

    var sectionColor: Color {
        if title.contains("THREAT LEVEL") { return .shieldRed }
        if title.contains("CRITICAL") { return .shieldOrange }
        if title.contains("NETWORK") || title.contains("MAP") { return .shieldBlue }
        if title.contains("HARDWARE") { return .shieldYellow }
        if title.contains("ACTIONS") { return .shieldGreen }
        if title.contains("TRACE") { return Color(hex: "#bf5af2") }
        return .shieldBlue
    }

    var sectionIcon: String {
        if title.contains("THREAT LEVEL") { return "shield.fill" }
        if title.contains("CRITICAL") { return "exclamationmark.octagon.fill" }
        if title.contains("NETWORK") || title.contains("MAP") { return "network" }
        if title.contains("HARDWARE") { return "cpu" }
        if title.contains("ACTIONS") { return "list.bullet.clipboard" }
        if title.contains("TRACE") { return "eye.trianglebadge.exclamationmark" }
        return "doc.text"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: sectionIcon)
                    .font(.system(size: 12))
                    .foregroundColor(sectionColor)
                Text(title)
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(sectionColor)
                    .tracking(0.5)
            }

            Text(body)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(sectionColor.opacity(0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(sectionColor.opacity(0.12), lineWidth: 1))
    }
}

// MARK: - Shared Empty State
struct EmptyStateView: View {
    let icon: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 36))
                .foregroundColor(.white.opacity(0.1))
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.25))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }
}

// MARK: - Severity Badge
struct SeverityBadge: View {
    let severity: Severity

    var body: some View {
        Text(severity.rawValue)
            .font(.system(size: 8, weight: .bold, design: .monospaced))
            .foregroundColor(severity.color)
            .tracking(0.8)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(severity.backgroundColor)
            .cornerRadius(4)
    }
}
