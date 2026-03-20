import SwiftUI

struct RFShieldView: View {
    @EnvironmentObject private var viewModel: ScanViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.rfTowers) { tower in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(tower.carrier).font(.headline)
                        Spacer()
                        Text(tower.status).foregroundStyle(tower.status == "Review" ? .shieldOrange : .shieldGreen)
                    }
                    Text("Band: \(tower.band)")
                    Text("Signal: \(tower.signalStrength) dBm").foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.shieldSurface)
            }
            .scrollContentBackground(.hidden)
            .background(Color.shieldBackground)
            .navigationTitle("RF Shield")
        }
    }
}
