import SwiftUI

// MARK: - Privacy View

struct PrivacyView: View {
    @State private var killSwitches = PrivacyKillSwitches()
    @State private var exposureScoring = ExposureScoring()

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Privacy Controls")) {
                    ForEach(PrivacyKillSwitches.availableSwitches, id: \.key) { item in
                        Toggle(item.label, isOn: Binding(
                            get: { killSwitches.isSwitchEnabled(name: item.key) },
                            set: { killSwitches.setSwitch(name: item.key, enabled: $0) }
                        ))
                    }
                }

                Section(header: Text("Exposure Score")) {
                    HStack {
                        Text("Current Score")
                        Spacer()
                        Text("\(exposureScoring.score)")
                            .fontWeight(.bold)
                            .foregroundColor(scoreColor)
                    }

                    ProgressView(value: min(Double(exposureScoring.score), 100), total: 100)
                        .progressViewStyle(LinearProgressViewStyle(tint: scoreColor))

                    Text(scoreDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section(header: Text("Simulate Activity")) {
                    Button("Simulate Tracking") {
                        exposureScoring.updateScore(forActivity: "tracking")
                    }
                    Button("Simulate Data Sharing") {
                        exposureScoring.updateScore(forActivity: "data-sharing")
                    }
                    Button("Reset Score") {
                        exposureScoring.reset()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Privacy")
        }
    }

    private var scoreColor: Color {
        switch exposureScoring.score {
        case 0..<20:   return .green
        case 20..<50:  return .yellow
        case 50..<80:  return .orange
        default:        return .red
        }
    }

    private var scoreDescription: String {
        switch exposureScoring.score {
        case 0..<20:   return "Your privacy exposure is minimal."
        case 20..<50:  return "Moderate exposure — review your settings."
        case 50..<80:  return "High exposure — take action to protect your privacy."
        default:        return "Critical exposure — your privacy is at significant risk."
        }
    }
}

// MARK: - Privacy Kill Switches

struct PrivacyKillSwitches {
    var switches: [String: Bool] = [:]

    struct SwitchItem {
        let key: String
        let label: String
    }

    static let availableSwitches: [SwitchItem] = [
        SwitchItem(key: "locationTracking",  label: "Location Tracking"),
        SwitchItem(key: "adTracking",        label: "Ad Tracking"),
        SwitchItem(key: "analyticsSharing",  label: "Analytics Sharing"),
        SwitchItem(key: "backgroundRefresh", label: "Background App Refresh"),
        SwitchItem(key: "dataSharing",       label: "Data Sharing with Third Parties"),
    ]

    mutating func setSwitch(name: String, enabled: Bool) {
        switches[name] = enabled
    }

    func isSwitchEnabled(name: String) -> Bool {
        switches[name] ?? false
    }
}

// MARK: - Exposure Scoring

struct ExposureScoring {
    var score: Int = 0

    mutating func updateScore(forActivity activity: String) {
        switch activity {
        case "tracking":     score += 5
        case "data-sharing": score += 10
        default:             score += 1
        }
    }

    mutating func reset() {
        score = 0
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
