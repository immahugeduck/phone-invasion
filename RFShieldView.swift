import SwiftUI

// MARK: - Root RF Shield View
struct RFShieldView: View {
    @StateObject private var detector = RogueTowerDetector()
    @StateObject private var monitor = CellTowerMonitor.shared
    @State private var selectedPanel: RFPanel = .live

    enum RFPanel: String, CaseIterable {
        case live     = "Live"
        case signals  = "Signals"
        case history  = "History"
        case bse      = "BSE Sigs"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Alert Banner (shown when threat detected)
            if detector.alertLevel >= .suspicious {
                AlertBanner(level: detector.alertLevel)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            // RF Header
            RFHeader(detector: detector, monitor: monitor)

            // Panel Selector
            HStack(spacing: 4) {
                ForEach(RFPanel.allCases, id: \.self) { panel in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedPanel = panel }
                    } label: {
                        Text(panel.rawValue)
                            .font(.system(size: 10, weight: selectedPanel == panel ? .bold : .regular, design: .monospaced))
                            .tracking(1)
                            .foregroundColor(selectedPanel == panel ? .shieldBlue : Color.white.opacity(0.3))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedPanel == panel ? Color.shieldBlue.opacity(0.12) : Color.clear)
                            .cornerRadius(6)
                    }
                }
                Spacer()
                // Monitor toggle
                Button {
                    if monitor.isMonitoring { monitor.stopMonitoring() }
                    else { monitor.startMonitoring() }
                } label: {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(monitor.isMonitoring ? Color.shieldGreen : Color.white.opacity(0.2))
                            .frame(width: 6, height: 6)
                            .if(monitor.isMonitoring) { v in v.modifier(PulseModifier()) }
                        Text(monitor.isMonitoring ? "LIVE" : "START")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(monitor.isMonitoring ? .shieldGreen : Color.white.opacity(0.4))
                            .tracking(1)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(monitor.isMonitoring ? Color.shieldGreen.opacity(0.1) : Color.white.opacity(0.04))
                    .cornerRadius(6)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.shieldBackground)

            Divider().background(Color.shieldBlue.opacity(0.1))

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    switch selectedPanel {
                    case .live:     LivePanel(detector: detector, monitor: monitor)
                    case .signals:  SignalsPanel(detector: detector)
                    case .history:  HistoryPanel(detector: detector)
                    case .bse:      BSEPanel()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - Alert Banner
struct AlertBanner: View {
    let level: RogueTowerDetector.AlertLevel
    @State private var visible = true

    var body: some View {
        if visible {
            HStack(spacing: 10) {
                Image(systemName: level.icon)
                    .font(.system(size: 14))
                    .foregroundColor(level.color)
                VStack(alignment: .leading, spacing: 1) {
                    Text("RF THREAT DETECTED — \(level.label)")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(level.color)
                        .tracking(0.5)
                    Text("Possible rogue base station in range. Review signals below.")
                        .font(.system(size: 10))
                        .foregroundColor(level.color.opacity(0.7))
                }
                Spacer()
                Button { withAnimation { visible = false } } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 11))
                        .foregroundColor(level.color.opacity(0.5))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(level.color.opacity(0.1))
            .overlay(alignment: .bottom) {
                Rectangle().fill(level.color.opacity(0.3)).frame(height: 1)
            }
        }
    }
}

// MARK: - RF Header
struct RFHeader: View {
    @ObservedObject var detector: RogueTowerDetector
    @ObservedObject var monitor: CellTowerMonitor

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 11))
                        .foregroundColor(.shieldBlue)
                    Text("RF FINGERPRINT GUARD")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.shieldBlue)
                        .tracking(1)
                }
                Text("Rogue Base Station Detector")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
            Spacer()

            // Risk Score Gauge
            if let verdict = detector.currentVerdict {
                VStack(spacing: 4) {
                    ZStack {
                        Circle().stroke(Color.white.opacity(0.06), lineWidth: 4).frame(width: 52, height: 52)
                        Circle()
                            .trim(from: 0, to: CGFloat(verdict.riskScore) / 100)
                            .stroke(verdict.verdict.color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 52, height: 52)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(response: 0.5), value: verdict.riskScore)
                        Text("\(verdict.riskScore)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(verdict.verdict.color)
                    }
                    Text("RISK")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.white.opacity(0.25))
                        .tracking(1)
                }
            } else {
                VStack(spacing: 4) {
                    Circle().stroke(Color.white.opacity(0.06), lineWidth: 4).frame(width: 52, height: 52)
                        .overlay(Text("—").font(.system(size: 14, design: .monospaced)).foregroundColor(Color.white.opacity(0.2)))
                    Text("RISK")
                        .font(.system(size: 8, design: .monospaced))
                        .foregroundColor(.white.opacity(0.25))
                        .tracking(1)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Live Panel
struct LivePanel: View {
    @ObservedObject var detector: RogueTowerDetector
    @ObservedObject var monitor: CellTowerMonitor

    var body: some View {
        VStack(spacing: 10) {
            // Current Tower Card
            CurrentTowerCard(observation: monitor.currentObservation, verdict: detector.currentVerdict)

            // Verdict display
            if let verdict = detector.currentVerdict {
                VerdictCard(verdict: verdict)
            }

            // Fingerprint Exposure
            FingerprintExposureCard(observation: monitor.currentObservation)

            // Baseline Status
            BaselineStatusCard(detector: detector)

            // Start Scan button
            Button {
                Task {
                    monitor.pollTowerData()
                    if let obs = monitor.currentObservation {
                        await detector.analyze(obs)
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    if detector.isAnalyzing {
                        ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .shieldBlue)).scaleEffect(0.7)
                    } else {
                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 13))
                    }
                    Text(detector.isAnalyzing ? "ANALYZING..." : "ANALYZE CURRENT TOWER")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .tracking(1)
                }
                .foregroundColor(.shieldBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 46)
                .background(Color.shieldBlue.opacity(0.1))
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.shieldBlue.opacity(0.25), lineWidth: 1))
            }
            .disabled(detector.isAnalyzing)
        }
    }
}

// MARK: - Current Tower Card
struct CurrentTowerCard: View {
    let observation: CellTowerObservation?
    let verdict: TowerVerdict?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("CURRENT TOWER")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Spacer()
                if let obs = observation {
                    RadioTypeBadge(radioType: obs.radioType)
                }
            }

            if let obs = observation {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    TowerParam(label: "CARRIER", value: obs.carrierName)
                    TowerParam(label: "CELL ID", value: "\(obs.cellID)")
                    TowerParam(label: "MCC / MNC", value: "\(obs.mcc) / \(obs.mnc)")
                    TowerParam(label: "LAC / TAC", value: "\(obs.lac)")
                    TowerParam(label: "RSSI", value: "\(Int(obs.rssi)) dBm",
                               color: obs.rssi > -60 ? .shieldRed : obs.rssi > -80 ? .shieldYellow : .shieldGreen)
                    if let rsrp = obs.rsrp {
                        TowerParam(label: "RSRP", value: "\(Int(rsrp)) dBm")
                    }
                    if let ta = obs.timingAdvance {
                        TowerParam(label: "TIMING ADV", value: "TA=\(ta) (~\(Int(obs.estimatedDistanceMeters ?? 0))m)",
                                   color: ta <= 1 ? .shieldRed : .shieldBlue)
                    }
                    TowerParam(label: "COUNTRY", value: obs.isoCountryCode.uppercased())
                }
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "antenna.radiowaves.left.and.right.slash")
                            .font(.system(size: 24)).foregroundColor(Color.white.opacity(0.15))
                        Text("Start monitoring to see live tower data")
                            .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.25))
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
            }
        }
        .padding(14)
        .background(Color.shieldSurface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.shieldBorder, lineWidth: 1))
    }
}

// MARK: - Tower Param Cell
struct TowerParam: View {
    let label: String
    let value: String
    var color: Color = Color.white.opacity(0.75)

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.shieldBlue)
                .tracking(1)
            Text(value)
                .font(.system(size: 11, design: .monospaced))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.black.opacity(0.2))
        .cornerRadius(6)
    }
}

// MARK: - Radio Type Badge
struct RadioTypeBadge: View {
    let radioType: RadioType

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(radioType.color).frame(width: 6, height: 6)
            Text(radioType.rawValue)
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(radioType.color)
                .tracking(0.5)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(radioType.color.opacity(0.1))
        .cornerRadius(5)
    }
}

// MARK: - Verdict Card
struct VerdictCard: View {
    let verdict: TowerVerdict

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(verdict.verdict.color.opacity(0.12)).frame(width: 44, height: 44)
                Image(systemName: verdict.verdict.icon)
                    .font(.system(size: 18)).foregroundColor(verdict.verdict.color)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(verdict.verdict.rawValue)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(verdict.verdict.color)
                    .tracking(1)
                Text("\(verdict.signals.count) anomaly signal\(verdict.signals.count == 1 ? "" : "s") · OpenCelliD: \(verdict.openCelliDMatch ? "✓ Verified" : "✗ Not Found")")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            Spacer()
            Text("\(verdict.riskScore)")
                .font(.system(size: 28, weight: .bold, design: .monospaced))
                .foregroundColor(verdict.verdict.color)
        }
        .padding(14)
        .background(verdict.verdict.color.opacity(0.07))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(verdict.verdict.color.opacity(0.2), lineWidth: 1))
    }
}

// MARK: - Fingerprint Exposure Card
struct FingerprintExposureCard: View {
    let observation: CellTowerObservation?

    var risk: RadioType.FingerprintRisk { observation?.radioType.fingerprintRisk ?? .unknown }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("RF FINGERPRINT EXPOSURE")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3)).tracking(1)
                Spacer()
                Text(risk.rawValue)
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(risk.color)
            }
            Text(riskExplanation)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.5))
                .lineSpacing(4)
            // Stability note
            HStack(spacing: 6) {
                Image(systemName: "clock.badge.exclamationmark")
                    .font(.system(size: 10)).foregroundColor(.shieldYellow)
                Text("NIST research: device RF fingerprint remains stable for 17+ days — once captured, you're identifiable across locations.")
                    .font(.system(size: 10))
                    .foregroundColor(.shieldYellow.opacity(0.7))
                    .lineSpacing(3)
            }
            .padding(9)
            .background(Color.shieldYellow.opacity(0.06))
            .cornerRadius(7)
        }
        .padding(14)
        .background(Color.shieldSurface)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.shieldBorder, lineWidth: 1))
    }

    var riskExplanation: String {
        switch observation?.radioType {
        case .gsm:  return "2G GSM has no mandatory encryption (A5/0 mode). Your hardware RF emissions are trivially capturable and linkable to your device indefinitely."
        case .wcdma: return "3G WCDMA provides some encryption but is vulnerable to downgrade attacks and passive RF fingerprinting at close range."
        case .lte:  return "4G LTE offers better privacy but RF hardware emissions are still unique to your device and capturable by passive receivers within range."
        case .nr:   return "5G NR includes SUPI/GUTI concealment, but RF hardware fingerprinting bypasses all protocol-layer privacy — your emissions are still device-unique."
        default:    return "Start monitoring to assess current RF fingerprint exposure level."
        }
    }
}

// MARK: - Baseline Status Card
struct BaselineStatusCard: View {
    @ObservedObject var detector: RogueTowerDetector

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain")
                .font(.system(size: 16)).foregroundColor(.shieldBlue)
            VStack(alignment: .leading, spacing: 3) {
                Text("ML BASELINE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3)).tracking(1)
                if detector.baselineObservationCount >= 50 {
                    Text("Active — \(detector.baselineObservationCount) observations trained")
                        .font(.system(size: 11)).foregroundColor(.shieldGreen)
                } else if detector.baselineObservationCount > 0 {
                    Text("Training — \(detector.baselineObservationCount)/50 observations (\(Int(Double(detector.baselineObservationCount)/50*100))%)")
                        .font(.system(size: 11)).foregroundColor(.shieldYellow)
                } else {
                    Text("Not started — begin monitoring to train local baseline")
                        .font(.system(size: 11)).foregroundColor(Color.white.opacity(0.35))
                }
            }
            Spacer()
            // Progress arc
            ZStack {
                Circle().stroke(Color.white.opacity(0.06), lineWidth: 3).frame(width: 30, height: 30)
                Circle()
                    .trim(from: 0, to: min(CGFloat(detector.baselineObservationCount) / 50, 1.0))
                    .stroke(detector.baselineObservationCount >= 50 ? Color.shieldGreen : Color.shieldBlue,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .frame(width: 30, height: 30).rotationEffect(.degrees(-90))
            }
        }
        .padding(12)
        .background(Color.shieldSurface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.shieldBorder, lineWidth: 1))
    }
}

// MARK: - Signals Panel
struct SignalsPanel: View {
    @ObservedObject var detector: RogueTowerDetector

    var body: some View {
        VStack(spacing: 8) {
            if let verdict = detector.currentVerdict, !verdict.signals.isEmpty {
                HStack {
                    Text("\(verdict.signals.count) SIGNALS DETECTED")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3)).tracking(1)
                    Spacer()
                    Text("Risk: \(verdict.riskScore)/100")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(verdict.verdict.color)
                }

                ForEach(verdict.signals.sorted { $0.severity.rawValue > $1.severity.rawValue }) { signal in
                    SignalCard(signal: signal)
                }
            } else {
                EmptyStateView(icon: "waveform.path.ecg", message: "No anomalies detected. Analyze a tower to see signals.")
            }
        }
    }
}

// MARK: - Signal Card
struct SignalCard: View {
    let signal: DetectionSignal
    @State private var expanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button { withAnimation(.easeInOut(duration: 0.2)) { expanded.toggle() } } label: {
                HStack(alignment: .top, spacing: 10) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(signal.severity.color)
                        .frame(width: 3, height: 38)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(signal.title)
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                        Text(signal.type.rawValue)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3)).tracking(0.5)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(signal.severity.label)
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(signal.severity.color).tracking(0.8)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(signal.severity.color.opacity(0.12))
                            .cornerRadius(3)
                        Text("\(Int(signal.confidence * 100))% conf")
                            .font(.system(size: 8, design: .monospaced))
                            .foregroundColor(.white.opacity(0.25))
                    }
                }
                .padding(12)
            }
            .buttonStyle(PlainButtonStyle())

            if expanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().background(Color.white.opacity(0.06))
                    Text(signal.detail)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(4)
                    if let raw = signal.rawValue {
                        Text(raw)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.shieldBlue)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.shieldSurface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(signal.severity.color.opacity(0.15), lineWidth: 1))
    }
}

// MARK: - History Panel
struct HistoryPanel: View {
    @ObservedObject var detector: RogueTowerDetector

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(detector.verdictHistory.count) TOWER ANALYSES")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3)).tracking(1)
                Spacer()
            }
            if detector.verdictHistory.isEmpty {
                EmptyStateView(icon: "clock", message: "Analyze towers to build history")
            } else {
                ForEach(detector.verdictHistory.reversed()) { verdict in
                    HistoryRow(verdict: verdict)
                }
            }
        }
    }
}

struct HistoryRow: View {
    let verdict: TowerVerdict

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: verdict.verdict.icon)
                .font(.system(size: 14)).foregroundColor(verdict.verdict.color)
            VStack(alignment: .leading, spacing: 2) {
                Text(verdict.verdict.rawValue)
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(verdict.verdict.color)
                Text("CellID \(verdict.observation.cellID) · \(verdict.observation.radioType.rawValue) · \(verdict.signals.count) signals")
                    .font(.system(size: 10)).foregroundColor(.white.opacity(0.3))
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(verdict.riskScore)")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(verdict.verdict.color)
                Text(verdict.generatedAt, style: .time)
                    .font(.system(size: 9)).foregroundColor(.white.opacity(0.2))
            }
        }
        .padding(12)
        .background(Color.shieldSurface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(verdict.verdict.color.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - BSE Reference Panel
struct BSEPanel: View {
    @State private var expanded: String? = nil

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("KNOWN BSE SIGNATURES")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3)).tracking(1)
                Spacer()
                Text("\(BSESignatureDatabase.signatures.count) PATTERNS")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundColor(.shieldBlue)
            }
            ForEach(BSESignatureDatabase.signatures, id: \.name) { sig in
                BSESignatureCard(signature: sig, isExpanded: expanded == sig.name) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        expanded = expanded == sig.name ? nil : sig.name
                    }
                }
            }
        }
    }
}

struct BSESignatureCard: View {
    let signature: BSESignatureDatabase.Signature
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(signature.name)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                        Text("\(signature.indicators.count) indicators")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10)).foregroundColor(.white.opacity(0.25))
                }
                .padding(13)
            }
            .buttonStyle(PlainButtonStyle())

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().background(Color.white.opacity(0.06))
                    Text(signature.description)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                        .lineSpacing(4)
                    ForEach(signature.indicators, id: \.field) { indicator in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: indicator.isMandatory ? "exclamationmark.circle.fill" : "circle")
                                .font(.system(size: 10))
                                .foregroundColor(indicator.isMandatory ? .shieldRed : .shieldBlue)
                                .padding(.top, 1)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(indicator.field.uppercased())
                                    .font(.system(size: 8, weight: .bold, design: .monospaced))
                                    .foregroundColor(.shieldBlue).tracking(1)
                                Text(indicator.pattern)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                }
                .padding(.horizontal, 13)
                .padding(.bottom, 12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.shieldSurface)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(
            isExpanded ? Color.shieldBlue.opacity(0.2) : Color.shieldBorder, lineWidth: 1))
    }
}
