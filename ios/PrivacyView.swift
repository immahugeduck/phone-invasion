import SwiftUI

struct PrivacyView: View {
    @StateObject private var viewModel = PrivacyViewModel()

    var body: some View {
        NavigationStack {
            List {
                Section("Exposure Score") {
                    Text("\(viewModel.exposureScore)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(.shieldBlue)
                }

                Section("Permissions") {
                    ForEach(viewModel.permissions) { permission in
                        Toggle(isOn: Binding(
                            get: { permission.enabled },
                            set: { _ in viewModel.toggle(permission) }
                        )) {
                            Label(permission.name, systemImage: permission.systemImage)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.shieldBackground)
            .navigationTitle("Privacy")
        }
    }
}
