import SwiftUI

struct BluetoothView: View {
    @StateObject private var viewModel = BluetoothViewModel(bluetoothManager: BluetoothManager())
    @State private var navigateToInitSection = false

    var body: some View {
        NavigationView { // Envolvendo em NavigationView
            VStack(spacing: 20) {
                Text("Bluetooth está \(viewModel.isScanning ? "Ativo" : "Desativado")")
                    .font(.headline)
                    .padding()

                Button(action: {
                    viewModel.isScanning ? viewModel.stopScanning() : viewModel.startScanning()
                }) {
                    Text(viewModel.isScanning ? "Parar Scanner" : "Iniciar Scanner")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(viewModel.isScanning ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                List(viewModel.discoveredDevices, id: \.self) { deviceName in
                    HStack {
                        Text(deviceName)
                        Spacer()
                        if viewModel.connectedDeviceName == deviceName {
                            Text("Conectado")
                                .foregroundColor(.green)
                        } else {
                            Button(action: {
                                viewModel.connectToDevice(named: deviceName)
                            }) {
                                Text("Conectar")
                            }
                        }
                    }
                }

                if let connectedDeviceName = viewModel.connectedDeviceName {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Detalhes do Dispositivo Conectado:")
                            .font(.headline)
                            .padding(.top)

                        Text("Nome: \(connectedDeviceName)")
                            .font(.subheadline)

                        Text(viewModel.connectedDeviceDetails)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Gerenciar Bluetooth")
        }
    }
}
