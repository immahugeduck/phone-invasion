import SwiftUI
import Combine

// MARK: - App State
class AppState: ObservableObject {
    @Published var scanCompleted = false
    @Published var threatCount = 0
}

// MARK: - Content View (Tab Container)
struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var scanVM = ScanViewModel()
    @State private var selectedTab: AppTab = .scan

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.shieldBackground.ignoresSafeArea()

            // Grid background
            GridBackground()

            VStack(spacing: 0) {
                // Header
                AppHeader(selectedTab: $selectedTab)

                // Tab Content
                TabContent(selectedTab: $selectedTab, scanVM: scanVM)

                Spacer(minLength: 0)
            }

            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, scanVM: scanVM)
        }
        .environmentObject(scanVM)
    }
}

// MARK: - Tab Enum
enum AppTab: String, CaseIterable {
    case scan     = "Scan"
    case trackers = "Trackers"
    case files    = "Files"
    case network  = "Network"
    case privacy  = "Privacy"
    case rf       = "RF Guard"
    case report   = "AI Report"

    var icon: String {
        switch self {
        case .scan:     return "shield.lefthalf.filled"
        case .trackers: return "antenna.radiowaves.left.and.right"
        case .files:    return "doc.badge.exclamationmark"
        case .network:  return "wifi.exclamationmark"
        case .privacy:  return "lock.shield"
        case .rf:       return "waveform.path.ecg.rectangle"
        case .report:   return "brain"
        }
    }
}

// MARK: - Tab Content Router
struct TabContent: View {
    @Binding var selectedTab: AppTab
    @ObservedObject var scanVM: ScanViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                switch selectedTab {
                case .scan:
                    ScanView(selectedTab: $selectedTab)
                case .trackers:
                    TrackersView()
                case .files:
                    FilesView()
                case .network:
                    NetworkView()
                case .privacy:
                    PrivacyView()
                case .rf:
                    RFShieldView()
                case .report:
                    AIReportView()
                }
            }
            .padding(.bottom, 90)
        }
    }
}

// MARK: - App Header
struct AppHeader: View {
    @EnvironmentObject var scanVM: ScanViewModel
    @Binding var selectedTab: AppTab

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("SHIELD·AI")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.shieldBlue)
                        .tracking(4)
                    Text("Privacy Scanner")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 7, height: 7)
                            .if(scanVM.phase == .scanning) { v in
                                v.modifier(PulseModifier())
                            }
                        Text(statusText)
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(statusColor)
                            .tracking(2)
                    }
                    Text("iOS 17 · iPhone")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.25))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)

            Divider().background(Color.shieldBlue.opacity(0.15))
        }
        .background(Color.shieldBackground.opacity(0.95))
    }

    var statusColor: Color {
        switch scanVM.phase {
        case .idle:     return Color.white.opacity(0.3)
        case .scanning: return .yellow
        case .done:     return .shieldGreen
        }
    }

    var statusText: String {
        switch scanVM.phase {
        case .idle:     return "STANDBY"
        case .scanning: return "SCANNING"
        case .done:     return "COMPLETE"
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: AppTab
    @ObservedObject var scanVM: ScanViewModel

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if tab == .report && scanVM.phase == .done {
                                Circle()
                                    .fill(Color.shieldBlue.opacity(0.2))
                                    .frame(width: 32, height: 32)
                            }
                            Image(systemName: tab.icon)
                                .font(.system(size: 16, weight: selectedTab == tab ? .semibold : .regular))
                                .foregroundColor(selectedTab == tab ? .shieldBlue : Color.white.opacity(0.3))
                        }
                        Text(tab == .report ? "AI" : tab == .rf ? "RF" : tab.rawValue)
                            .font(.system(size: 9, weight: selectedTab == tab ? .bold : .regular, design: .monospaced))
                            .foregroundColor(selectedTab == tab ? .shieldBlue : Color.white.opacity(0.25))
                            .tracking(0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 20)
        .background(
            ZStack {
                Color.shieldBackground
                Rectangle()
                    .fill(Color.shieldBlue.opacity(0.06))
            }
            .overlay(alignment: .top) {
                Divider().background(Color.shieldBlue.opacity(0.15))
            }
        )
    }
}

// MARK: - Grid Background
struct GridBackground: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 32
                var x: CGFloat = 0
                while x <= geo.size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: geo.size.height))
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.shieldBlue.opacity(0.03), lineWidth: 1)
        }
        .ignoresSafeArea()
    }
}

// MARK: - View Extension
extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Pulse Modifier
struct PulseModifier: ViewModifier {
    @State private var scale: CGFloat = 1.0

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    scale = 1.4
                }
            }
    }
}
