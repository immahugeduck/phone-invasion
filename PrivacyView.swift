import SwiftUI

struct PrivacyView: View {
    @StateObject private var privacyVM = PrivacyViewModel()

    var body: some View {
        VStack(spacing: 12) {
            // Exposure Score
            ExposureScoreCard(vm: privacyVM)
                .padding(.horizontal, 16)

            // Section header
            HStack {
                Text("PRIVACY KILL SWITCHES")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                Spacer()
                Text("TAP TO TOGGLE")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.white.opacity(0.18))
                    .tracking(1)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)

            LazyVStack(spacing: 8) {
                ForEach(privacyVM.permissions.indices, id: \.self) { idx in
                    PrivacyToggleCard(
                        permission: privacyVM.permissions[idx],
                        onToggle: { privacyVM.togglePermission(privacyVM.permissions[idx].key) }
                    )
                }
            }
            .padding(.horizontal, 16)

            // iOS Settings note
            InfoNote(message: "Kill switches open iOS Settings where you can revoke permissions per-app. iOS sandboxing requires user action in Settings.")
                .padding(.horizontal, 16)
                .padding(.top, 4)
        }
        .padding(.top, 12)
    }
}

// MARK: - Exposure Score Card
struct ExposureScoreCard: View {
    @ObservedObject var vm: PrivacyViewModel
    @State private var animatedScore: Int = 0

    var body: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("EXPOSURE SCORE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .tracking(1)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(animatedScore)")
                            .font(.system(size: 42, weight: .bold, design: .monospaced))
                            .foregroundColor(vm.exposureColor)
                        Text("/ 100")
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.white.opacity(0.2))
                    }
                    Text(vm.exposureLabel)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(vm.exposureColor)
                        .tracking(1)
                }

                Spacer()

                // Radial gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 6)
                        .frame(width: 70, height: 70)
                    Circle()
                        .trim(from: 0, to: CGFloat(vm.exposureScore) / 100)
                        .stroke(vm.exposureColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 70, height: 70)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.6), value: vm.exposureScore)
                    Image(systemName: vm.exposureScore > 60 ? "exclamationmark.shield.fill" : "checkmark.shield.fill")
                        .font(.system(size: 20))
                        .foregroundColor(vm.exposureColor)
                }
            }

            // Score bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 5)
                    RoundedRectangle(cornerRadius: 3)
                        .fill(LinearGradient(colors: [.shieldGreen, .shieldYellow, .shieldOrange, .shieldRed],
                                             startPoint: .leading, endPoint: .trailing))
                        .frame(width: geo.size.width * CGFloat(vm.exposureScore) / 100, height: 5)
                        .animation(.spring(response: 0.6), value: vm.exposureScore)
                }
            }
            .frame(height: 5)

            Text("Disable sensors below to reduce your exposure score")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.25))
        }
        .padding(16)
        .background(vm.exposureColor.opacity(0.06))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(vm.exposureColor.opacity(0.2), lineWidth: 1))
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                animatedScore = vm.exposureScore
            }
        }
        .onChange(of: vm.exposureScore) { newVal in
            withAnimation(.spring(response: 0.5)) { animatedScore = newVal }
        }
    }
}

// MARK: - Privacy Toggle Card
struct PrivacyToggleCard: View {
    let permission: PrivacyPermission
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 14) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(permission.isEnabled ? Color.shieldRed.opacity(0.1) : Color.shieldGreen.opacity(0.1))
                        .frame(width: 42, height: 42)
                    Image(systemName: permission.icon)
                        .font(.system(size: 17))
                        .foregroundColor(permission.isEnabled ? .shieldRed : .shieldGreen)
                }
                .animation(.easeInOut(duration: 0.3), value: permission.isEnabled)

                VStack(alignment: .leading, spacing: 3) {
                    Text(permission.label)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                    Text(permission.description)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.3))
                }

                Spacer()

                // Toggle
                Toggle("", isOn: Binding(
                    get: { permission.isEnabled },
                    set: { _ in onToggle() }
                ))
                .toggleStyle(ShieldToggleStyle())
                .labelsHidden()
            }
            .padding(14)

            // Risk label
            HStack(spacing: 6) {
                Image(systemName: permission.isEnabled ? "exclamationmark.circle.fill" : "checkmark.circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(permission.isEnabled ? .shieldOrange : .shieldGreen)
                Text(permission.riskActive)
                    .font(.system(size: 10))
                    .foregroundColor(permission.isEnabled ? .shieldOrange.opacity(0.8) : .shieldGreen.opacity(0.7))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 12)
        }
        .background(Color.shieldSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    permission.isEnabled ? Color.shieldRed.opacity(0.15) : Color.shieldGreen.opacity(0.15),
                    lineWidth: 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: permission.isEnabled)
    }
}

// MARK: - Custom Toggle Style
struct ShieldToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14)
                .fill(configuration.isOn ? Color.shieldRed : Color.shieldGreen)
                .frame(width: 46, height: 28)
            Circle()
                .fill(.white)
                .frame(width: 22, height: 22)
                .offset(x: configuration.isOn ? 9 : -9)
                .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isOn)
        .onTapGesture { configuration.isOn.toggle() }
    }
}

// MARK: - Info Note
struct InfoNote: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 12))
                .foregroundColor(.shieldBlue.opacity(0.6))
                .padding(.top, 1)
            Text(message)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.3))
                .lineSpacing(3)
        }
        .padding(12)
        .background(Color.shieldBlue.opacity(0.04))
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.shieldBlue.opacity(0.1), lineWidth: 1))
    }
}
