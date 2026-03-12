import SwiftUI

struct NetworkView: View {
    @State private var isConnected: Bool = false
    @State private var connectionType: String = ""

    var body: some View {
        VStack {
            Text("Network Status")
                .font(.largeTitle)
                .padding()

            Text(isConnected ? "Connected" : "Not Connected")
                .font(.title)
                .foregroundColor(isConnected ? .green : .red)
                .padding()

            if isConnected {
                Text("Connection Type: \(connectionType)")
                    .font(.headline)
                    .padding()
            }
        }
        .onAppear(perform: checkNetworkStatus)
    }

    private func checkNetworkStatus() {
        // Simulated network check - replace with actual implementation 
        // Here we would use a network reachability API to determine status
        let isConnectedNow = true // Simulating a connection
        let connectionTypeNow = "WiFi" // Simulating connection type

        isConnected = isConnectedNow
        connectionType = connectionTypeNow
    }
}

struct NetworkView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkView()
    }
}