//
//  SensorDataSource.swift
//  SensorSuite
//
//  Created by David Coffman on 11/8/21.
//

import Foundation
import CoreBluetooth

enum BLEUUID: String, CaseIterable {
    case SERVICE = "eaa636ce-ffc0-4444-923e-cb0622a6772f"
    case CONFIG = "7815d597-62b4-4d3a-a58f-c4b2d9ae13e3"
    case LEFT_LIDAR = "bcbc0b7d-c813-48c4-ac04-5289cff3ebf6"
    case CENTER_LIDAR = "51283344-4a85-472f-aef5-8023253bc0a5"
    case RIGHT_LIDAR = "8799087d-e65a-4ea3-9331-7222cc242da2"
    
    static let ALL_CHARACTERISTICS = BLEUUID.allCases.filter({return $0 != .SERVICE}).map({return $0.uuid()})
    
    private static let UUID_TO_CASE: [CBUUID: BLEUUID] = {
        var dict = [CBUUID: BLEUUID]()
        
        for _case in BLEUUID.allCases {
            dict[_case.uuid()] = _case
        }
        
        return dict
    }()
    
    static func from(_ uuid: CBUUID) -> BLEUUID? {
        return UUID_TO_CASE[uuid]
    }
    
    func uuid() -> CBUUID {
        return CBUUID(string: self.rawValue)
    }
}

class SensorSuite: NSObject, ObservableObject {
    
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral?
    var characteristicMap = [BLEUUID: CBCharacteristic]()
    var characteristicValues = [BLEUUID: String]()
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension SensorSuite: CBCentralManagerDelegate {
    // As long as BT radio on, try to connect
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }
        self.centralManager.scanForPeripherals(withServices: [BLEUUID.SERVICE.uuid()], options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }
    
    // On device discovery, connect
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.centralManager.stopScan()
        peripheral.delegate = self
        self.peripheral = peripheral
        self.centralManager.connect(peripheral, options: nil)
    }
    
    // On successful connection
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        guard peripheral == self.peripheral else { return }
        peripheral.discoverServices([BLEUUID.SERVICE.uuid()])
    }
}

extension SensorSuite: CBPeripheralDelegate {
    // On service discovery, discover characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard
            let services = peripheral.services,
            let service = services.filter({return $0.uuid == BLEUUID.SERVICE.uuid()}).first
        else { return }
        
        peripheral.discoverCharacteristics(BLEUUID.ALL_CHARACTERISTICS, for: service)
    }
    
    // On characteristic discovery
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard
            peripheral == self.peripheral,
            let characteristics = service.characteristics
        else { return }
        
        for characteristic in characteristics {
            guard let uuid = BLEUUID.from(characteristic.uuid) else { continue }
            characteristicMap[uuid] = characteristic
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    // On value write to characteristic (i.e. other device writes data)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard
            let value = characteristic.value,
            let uuid = BLEUUID.from(characteristic.uuid),
            let dataAsStr = String(data: value, encoding: .utf8)
        else { return }
        
        characteristicValues[uuid] = dataAsStr
    }
}

extension SensorSuite: SensorDataSource {
    
    private static var SENSOR_TO_BLEUUID: [Sensor: BLEUUID] = [
        .LEFT_LIDAR : .LEFT_LIDAR,
        .CENTER_LIDAR: .CENTER_LIDAR,
        .RIGHT_LIDAR: .RIGHT_LIDAR
    ]
    
    func getDataForSensor(sensor: Sensor) -> Double {
        guard
            let uuid = SensorSuite.SENSOR_TO_BLEUUID[sensor],
            let dataString = characteristicValues[uuid],
            let dataDouble = Double(dataString)
        else { return -1 }
        
        return dataDouble
    }
}

extension SensorSuite: SensorController {
    func powerSensorsOff() {
        print("Powering off!")
        guard
            let target = self.characteristicMap[.CONFIG],
            let peripheral = self.peripheral
        else { return }
        
        let data = "1".data(using: .utf8)!
        
        peripheral.writeValue(data, for: target, type: .withoutResponse)
    }
    
    func powerSensorsOn() {
        print("Powering on!")
        guard
            let target = self.characteristicMap[.CONFIG],
            let peripheral = self.peripheral
        else { return }
        
        let data = "2".data(using: .utf8)!
        
        peripheral.writeValue(data, for: target, type: .withoutResponse)
    }
}
