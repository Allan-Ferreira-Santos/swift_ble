import Combine
import CoreBluetooth

class BluetoothManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    @Published var listPeripheral: [String] = []
    @Published var connectedPeripheralName: String?
    @Published var connectedDeviceDetails: String = ""
    
    var statusBlueTooth: Bool = false
    var namePeripherals: String = ""

    private var central: CBCentralManager!
    private var connectedPeripheral: CBPeripheral?

    override init() {
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        print("Iniciando scanner...")
        if central.state == .poweredOn {
            central.scanForPeripherals(withServices: nil)
        } else {
            print("Bluetooth não está ativado.")
        }
    }

    func stopScanner() {
        print("Stop scanner...")
        if central.state == .poweredOn {
            central.stopScan()
        } else {
            print("Bluetooth não está ativado.")
        }
    }

    func connect(named name: String) {
        namePeripherals = name
        startScanning()
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        guard let name = peripheral.name else { return }

        if !listPeripheral.contains(name) {
            listPeripheral.append(name)
        }

        if name == namePeripherals {
            print("Dispositivo específico encontrado: \(name)")
            connectedPeripheral = peripheral
            central.connect(peripheral)
            central.stopScan()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        print("Conectado ao periférico: \(peripheral.name ?? "Sem Nome")")
        connectedPeripheralName = peripheral.name
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Erro ao descobrir serviços: \(error.localizedDescription)")
            return
        }

        var details = "Dispositivo: \(peripheral.name ?? "Sem Nome")\n"

        if let services = peripheral.services {
            for service in services {
                details += "\nServiço: \(service.uuid)"
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
        connectedDeviceDetails = details
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("Erro ao descobrir características: \(error.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else { return }

        var details = connectedDeviceDetails
        for characteristic in characteristics {
            details += "\nCaracterística: \(characteristic.uuid), Propriedades: \(characteristic.properties)"
        }
        connectedDeviceDetails = details
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth está ativado.")
            statusBlueTooth = true
        case .poweredOff:
            print("Bluetooth está desativado.")
            statusBlueTooth = false
        case .unsupported:
            print("Dispositivo não suporta Bluetooth.")
        case .unauthorized:
            print("Permissões de Bluetooth não concedidas.")
        case .resetting:
            print("Bluetooth está reiniciando.")
        case .unknown:
            print("Estado do Bluetooth desconhecido.")
        @unknown default:
            print("Estado não tratado.")
        }
    }
}
