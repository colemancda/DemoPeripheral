//
//  PeripheralController.swift
//  DemoPeripheral
//
//  Created by Alsey Coleman Miller on 7/13/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

#if os(Linux)
    import Glibc
#elseif os(OSX)
    import Darwin.C
#endif

import SwiftFoundation
import Bluetooth
import GATT

/// The periperal's main controller.
final class PeripheralController {
    
    static let shared = PeripheralController()
    
    // MARK: - Properties
    
    let peripheral = PeripheralManager()
    
    let identifier = UUID()
    
    private(set) var status: Bool = true {
        
        didSet { didChangeStatus(oldValue: oldValue) }
    }
    
    lazy var appLED: GPIO = {
        
        let gpio = GPIO(sunXi: SunXiGPIO(letter: .A, pin: 1)) // Change to whatever you want, depending on your hardware
        
        gpio.direction = .OUT
        
        return gpio
    }()
    
    // MARK: - Initialization
    
    private init() {
        
        // setup server
        peripheral.log = { print("Peripheral: " + $0) }
        peripheral.willWrite = willWrite
        
        // add service to GATT server
        addPeripheralService()
        
        // turn on app LED
        appLED.value = 1
        
        // start GATT server
        
        let beacon = Beacon(UUID: BeaconUUID, major: 0, minor: 0, RSSI: -56)
        
        #if os(Linux)
            do { try peripheral.start(beacon: beacon) }
            catch { fatalError("Could not start peripheral: \(error)") }
        #elseif os(OSX)
            do { try peripheral.start() }
            catch { fatalError("Could not start peripheral: \(error)") }
        #endif
        
        print("Initialized Peripheral \(identifier)")
    }
    
    // MARK: - Private Methods
    
    private func addPeripheralService() {
        
        let identifierValue = PeripheralService.Identifier(value: self.identifier).toBigEndian()
        
        let identifier = Characteristic(UUID: PeripheralService.Identifier.UUID, value: identifierValue, permissions: [.Read], properties: [.Read])
        
        let statusValue = PeripheralService.Status(value: self.status).toBigEndian()
        
        let status = Characteristic(UUID: PeripheralService.Status.UUID, value: statusValue, permissions: [.Read, .Write], properties: [.Read, .Write])
        
        let periperhalService = Service(UUID: PeripheralService.UUID, primary: true, characteristics: [identifier, status])
        
        let _ = try! peripheral.add(service: periperhalService)
    }
    
    private func didChangeStatus(oldValue: Bool) {
        
        print("Status \(oldValue) -> \(status)")
        
        peripheral[characteristic: PeripheralService.Status.UUID] = PeripheralService.Status(value: self.status).toBigEndian()
        
        // turn on / off LED
        #if arch(arm)
        appLED.value = status != 0
        #endif
    }
    
    private func willWrite(central: Central, UUID: BluetoothUUID, value: Data, newValue: Data) -> Bluetooth.ATT.Error? {
        
        switch UUID {
            
        case PeripheralService.Status.UUID:
            
            guard let status = PeripheralService.Status.init(bigEndian: newValue)
                else { return ATT.Error.InvalidAttributeValueLength }
            
            // set new value
            self.status = status.value.boolValue
            
        default: fatalError("Writing to unknown characteristic \(UUID)")
        }
        
        return nil
    }
}
