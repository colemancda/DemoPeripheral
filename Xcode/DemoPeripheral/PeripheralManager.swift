//
//  PeripheralManager.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

#if os(OSX) || os(iOS)
    
    import SwiftFoundation
    import Bluetooth
    import GATT
    import CoreBluetooth
    
    public final class PeripheralManager {
        
        // MARK: - Initialization
        
        public static let shared: PeripheralManager = PeripheralManager()
        
        // MARK: - Properties
        
        public var log: ((String) -> ())? {
            
            get { return internalManager.log }
            
            set { internalManager.log = newValue }
        }
        
        public var scanning = Observable(false)
        
        public var connectionTimeout: Int = 5
        
        public let foundDevices = Observable([Device]())
        
        public lazy var state: Observable<CBCentralManagerState> = unsafeBitCast(Observable(self.internalManager.state), to: Observable<CBCentralManagerState>.self)
        
        // MARK: - Private Properties
        
        private lazy var internalManager: CentralManager = {
            
            let central = CentralManager()
            
            // lazy initialization for CBCentralManager
            let _ = central.state
            
            central.stateChanged = { self.state.value = $0 }
            
            return central
        }()
        
        // MARK: - Subscripting
        
        public private(set) subscript (identifier: UUID) -> Device? {
            
            get {
                
                guard let index = foundDevices.value.index(where: { $0.identifier == identifier })
                    else { return nil }
                
                return foundDevices.value[index]
            }
            
            set {
                
                guard let index = foundDevices.value.index(where: { $0.identifier == identifier })
                    else { fatalError("Invalid index") }
                
                guard let newDevice = newValue
                    else { foundDevices.value.remove(at: index); return }
                
                foundDevices.value[index] = newDevice
            }
        }
        
        // MARK: - Methods
        
        /// Scans for a peripheral.
        ///
        /// - Parameter duration: The duration of the scan.
        ///
        /// - Returns: The peripherals found.
        public func scan(duration: Int = 3) throws {
            
            assert(self.internalManager.state == .poweredOn, "Should only scan when powered on")
            
            log?("Scanning...")
            
            scanning.value = true
            
            internalManager.disconnectAll()
            
            let foundDevices = self.internalManager.scan(duration: duration)
            
            if foundDevices.count > 0 { self.log?("Found \(foundDevices.count) peripherals") }
            
            var devices = [Device]()
            
            for peripheral in foundDevices {
                
                do { try self.internalManager.connect(to: peripheral) }
                    
                catch { log?("Cound not connect to \(peripheral.identifier) (\(error))"); continue }
                
                guard let services = try? self.internalManager.discoverServices(for: peripheral)
                    else { continue }
                
                // found device
                if services.contains(where: { $0.UUID == PeripheralService.UUID }) {
                    
                    guard let foundDevice = try? self.foundDevice(peripheral: peripheral)
                        else { continue }
                    
                    devices.append(foundDevice)
                }
                
                // disconnect
                internalManager.disconnect(peripheral: peripheral)
            }
            
            scanning.value = false
            
            self.foundDevices.value = devices
        }
        
        public func clear() {
            
            foundDevices.value = []
        }
        
        public func disconnect(device: Device) {
            
            internalManager.disconnect(peripheral: device.peripheral)
        }
        
        // MARK: Peripheral Actions
        
        /// Set the new value for the peripheral's status characteristic.
        public func setStatus(_ identifier: UUID, value: Bool) throws {
            
            guard let device = self[identifier]
                else { throw PeripheralManagerError.noPeripheral }
            
            return try peripheralAction(peripheral: device.peripheral, characteristics: [PeripheralService.Status.UUID]) {
                
                // set new status value
                let status = PeripheralService.Status.init(value: value)
                
                try self.internalManager.write(data: status.toBigEndian(), response: true, characteristic: PeripheralService.Status.UUID, service: PeripheralService.UUID, peripheral: device.peripheral)
                
                // update cached device value
                self[identifier]?.status = value
            }
        }
        
        // MARK: - Private Methods
        
        /// Connects to the peripheral, fetches the data, and performs the action, and disconnects.
        private func peripheralAction<T>(peripheral: Peripheral, characteristics: [BluetoothUUID], action: () throws -> (T)) throws -> T {
            
            // connect first
            try internalManager.connect(to: peripheral, timeout: connectionTimeout)
            
            defer { internalManager.disconnect(peripheral: peripheral) }
            
            // discover peripheral service
            let services = try self.internalManager.discoverServices(for: peripheral)
            
            guard services.contains(where: { $0.UUID == PeripheralService.UUID })
                else { throw PeripheralManagerError.peripheralServiceNotFound }
            
            // read characteristic
            
            let foundCharacteristics = try internalManager.discoverCharacteristics(for: PeripheralService.UUID, peripheral: peripheral)
            
            for requiredCharacteristic in characteristics {
                
                guard foundCharacteristics.contains(where: { $0.UUID == requiredCharacteristic })
                    else { throw PeripheralManagerError.characteristicNotFound(requiredCharacteristic) }
            }
            
            // perform action
            return try action()
        }
        
        private func foundDevice(peripheral: Peripheral) throws -> Device {
            
            log?("Found device peripheral \(peripheral.identifier)")
            
            // get peripheral status
            
            let characteristics = try internalManager.discoverCharacteristics(for: PeripheralService.UUID, peripheral: peripheral)
            
            guard characteristics.contains(where: { $0.UUID == PeripheralService.Status.UUID })
                else { throw PeripheralManagerError.characteristicNotFound(PeripheralService.Status.UUID) }
            
            let statusValue = try internalManager.read(characteristic: PeripheralService.Status.UUID, service: PeripheralService.UUID, peripheral: peripheral)
            
            guard let status = PeripheralService.Status.init(bigEndian: statusValue)
                else { throw PeripheralManagerError.invalidCharacteristicValue(PeripheralService.Status.UUID) }
            
            // get peripheral UUID
            
            guard characteristics.contains(where: { $0.UUID == PeripheralService.Identifier.UUID })
                else { throw PeripheralManagerError.characteristicNotFound(PeripheralService.Identifier.UUID) }
            
            let identifierValue = try internalManager.read(characteristic: PeripheralService.Identifier.UUID, service: PeripheralService.UUID, peripheral: peripheral)
            
            guard let identifier = PeripheralService.Identifier.init(bigEndian: identifierValue)
                else { throw PeripheralManagerError.invalidCharacteristicValue(PeripheralService.Identifier.UUID) }
            
            
            log?("Device \((peripheral, identifier.value, status))")
            
            return Device(peripheral: peripheral, identifier: identifier.value, status: status.value.boolValue)
        }
    }
    
    public enum PeripheralManagerError: Error {
        
        case noPeripheral
        case peripheralServiceNotFound
        case characteristicNotFound(BluetoothUUID)
        case invalidCharacteristicValue(BluetoothUUID)
    }
    
    public extension PeripheralManager {
        
        public struct Device {
            
            public let peripheral: Peripheral
            public let identifier: UUID
            public var status: Bool
        }
    }
    
#endif
