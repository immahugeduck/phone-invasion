import SwiftUI

struct ScanView: View {
    @EnvironmentObject var scanVM: ScanViewModel
    @Binding var selectedTab: AppTab
    @State private var orbRotation: Double = 0
    @State private var ringScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 0) {
            // Scan orb section
            ZStack {
                // Ambient glow
                if scanVM.phase == .scanning {
                    Circle()
                        .fill(Color.shieldBlue.opacity(0.06))
                        .frame(width: 260, height: 260)
                        .blur(radius: 30)
                }

                // Outer rings
                ForEach(0..<3) { i in
                    Circle()
                        .stroke(Color.shieldBlue.opacity(scanVM.phase == .scanning ? 0.12 : 0.05), lineWidth: 1)
                        .frame(width: CGFloat(140 + i * 30), height: CGFloat(140 + i * 30))
                        .scaleEffect(scanVM.phase == .scanning ? ringScale + CGFloat(i) * 0.05 : 1.0)
                        .animation(
                            scanVM.phase == .scanning
                                ? .easeInOut(duration: 1.2 + Double(i) * 0.3).repeatForever(autoreverses: true)
                                : .default,
                            value: ringScale
                        )
                }

                // Progress arc
                if scanVM.phase != .idle {
                    Circle()
                        .trim(from: 0, to: scanVM.progress / 100)
                        .stroke(
                            AngularGradient(colors: [.shieldBlue.opacity(0.3), .shieldBlue], center: .center),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 148, height: 148)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: scanVM.progress)
                }

                // Core orb
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: orbGradientColors,
                                center: .center,
                                startRadius: 0,
                                endRadius: 55
                            )
                        )
                        .frame(width: 110, height: 110)

                    Circle()
                        .stroke(Color.shieldBlue.opacity(scanVM.phase == .scanning ? 0.5 : 0.15), lineWidth: 1.5)
                        .frame(width: 110, height: 110)

                    // Inner icon
                    Group {
                        if scanVM.phase == .done {
                            Image(systemName: "checkmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.shieldGreen)
                        } else if scanVM.phase == .scanning {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 30))
                                .foregroundColor(.shieldBlue)
                                .rotationEffect(.degrees(orbRotation))
                        } else {
                            Image(systemName: "shield.lefthalf.filled")
                                .font(.system(size: 30))
                                .foregroundColor(.shieldBlue.opacity(0.6))
                        }
                    }
                }
                .shadow(color: orbShadowColor, radius: 20)
            }
            .frame(height: 240)
            .onAppear {
                withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                    orbRotation = 360
                }
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    ringScale = 1.08
                }
            }

            // Progress label
            if scanVM.phase != .idle {
                Text("\(Int(scanVM.progress))%")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.shieldBlue)
                    .animation(.none, value: scanVM.progress)
            }

            // Scan button
            Button {
                scanVM.startScan()
            } label: {
                Text(scanVM.phase == .idle ? "DEEP SCAN" : scanVM.phase == .scanning ? "SCANNING..." : "RE-SCAN")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(scanVM.phase == .scanning ? .shieldBlue : .black)
                    .frame(width: 180, height: 46)
                    .background(
                        scanVM.phase == .scanning
                            ? Color.shieldBlue.opacity(0.1)
                            : LinearGradient(colors: [.shieldBlue, Color(hex: "#0064c8")], startPoint: .leading, endPoint: .trailing)
                    )
                    .cornerRadius(14)
                    .shadow(color: .shieldBlue.opacity(0.3), radius: 12)
            }
            .disabled(scanVM.phase == .scanning)
            .padding(.top, 16)

            // Threat summary cards (post-scan)
            if scanVM.phase == .done {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ThreatCard(icon: "antenna.radiowaves.left.and.right", label: "Trackers",
                               count: scanVM.trackers.count, color: .shieldOrange)
                    ThreatCard(icon: "doc.badge.exclamationmark", label: "Suspicious Files",
                               count: scanVM.suspiciousFiles.count, color: .shieldRed)
                    ThreatCard(icon: "wifi.exclamationmark", label: "Network Risks",
                               count: scanVM.networkRiskCount, color: .shieldYellow)
                    ThreatCard(icon: "exclamationmark.triangle.fill", label: "Critical",
                               count: scanVM.criticalCount, color: .shieldRed)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)

                // Overall risk badge
                HStack {
                    Image(systemName: "shield.fill")
                    Text("OVERALL RISK: \(scanVM.overallRisk)")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(scanVM.overallRiskColor)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(scanVM.overallRiskColor.opacity(0.1))
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(scanVM.overallRiskColor.opacity(0.3), lineWidth: 1))
                .padding(.top, 12)

                // View AI Report CTA
                Button {
                    selectedTab = .report
                } label: {
                    HStack {
                        Image(systemName: "brain")
                        Text("VIEW AI THREAT REPORT")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .tracking(1)
                    }
                    .foregroundColor(.shieldBlue)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.shieldBlue.opacity(0.08))
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.shieldBlue.opacity(0.2), lineWidth: 1))
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }

            // Scan log
            if !scanVM.logs.isEmpty {
                ScanLogView()
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
            }

            Spacer(minLength: 20)
        }
        .padding(.top, 16)
    }

    var orbGradientColors: [Color] {
        switch scanVM.phase {
        case .idle:     return [Color.shieldBlue.opacity(0.08), Color.clear]
        case .scanning: return [Color.shieldBlue.opacity(0.25), Color(hex: "#0064c8").opacity(0.1), Color.clear]
        case .done:     return [Color.shieldGreen.opacity(0.2), Color.clear]
        }
    }

    var orbShadowColor: Color {
        switch scanVM.phase {
        case .idle:     return .clear
        case .scanning: return .shieldBlue.opacity(0.2)
        case .done:     return .shieldGreen.opacity(0.15)
        }
    }
}

// MARK: - Threat Card
struct ThreatCard: View {
    let icon: String
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
            Text("\(count)")
                .font(.system(size: 26, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, design: .monospaced))
                .foregroundColor(.white.opacity(0.35))
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.shieldSurface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.shieldBorder, lineWidth: 1))
    }
}

// MARK: - Scan Log View
struct ScanLogView: View {
    @EnvironmentObject var scanVM: ScanViewModel

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(scanVM.logs) { entry in
                        Text(entry.message)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(entry.color)
                            .id(entry.id)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
            }
            .frame(height: 180)
            .background(Color.black.opacity(0.4))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.shieldBlue.opacity(0.08), lineWidth: 1))
            .onChange(of: scanVM.logs.count) { _ in
                if let last = scanVM.logs.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }
}
