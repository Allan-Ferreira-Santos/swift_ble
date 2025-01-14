import Foundation
import Combine

class BluetoothViewModel: ObservableObject {
    private var bluetoothManager: BluetoothManager
    
    @Published var isBluetoothEnabled: Bool = false
    @Published var isScanning: Bool = false
    @Published var discoveredDevices: [String] = []
    @Published var connectedDeviceName: String? = nil
    @Published var connectedDeviceDetails: String = ""

    private var cancellables: Set<AnyCancellable> = []

    init(bluetoothManager: BluetoothManager) {
        self.bluetoothManager = bluetoothManager
        
        
        bluetoothManager.$listPeripheral
            .receive(on: DispatchQueue.main)
            .assign(to: &$discoveredDevices)
        
        bluetoothManager.$connectedPeripheralName
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectedDeviceName)
        
        bluetoothManager.$connectedDeviceDetails
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectedDeviceDetails)
    }

    func startScanning() {
        print("Iniciando scanner...")
        bluetoothManager.startScanning()
        isScanning = true
    }
    
    func stopScanning() {
        print("Parando scanner...")
        bluetoothManager.stopScanner()
        isScanning = false
    }
    
    func connectToDevice(named deviceName: String) {
        print("Conectando ao dispositivo: \(deviceName)")
        bluetoothManager.connect(named: deviceName)
        connectedDeviceName = deviceName
    }
    
    func disconnectDevice() {
        print("Desconexão de dispositivo ainda não implementada.")
        
    }
}
