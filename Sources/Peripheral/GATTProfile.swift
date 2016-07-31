//
//  GATTProfile.swift
//  DemoPeripheral
//
//  Created by Alsey Coleman Miller on 7/13/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Foundation
#endif

import SwiftFoundation
import Bluetooth

public protocol GATTProfileService {
    
    static var UUID: BluetoothUUID { get }
}

public protocol GATTProfileCharacteristic {
    
    static var UUID: BluetoothUUID { get }
    
    init?(bigEndian: Data)
    
    func toBigEndian() -> Data
}

public struct PeripheralService: GATTProfileService {
    
    public static let UUID = BluetoothUUID(rawValue: "DE3A06A1-3BD7-4DB7-B72E-997DBBF9BCD6")!
    
    /// The UUID identifier (16 bytes) (read-only)
    public struct Identifier: GATTProfileCharacteristic {
        
        public static let UUID = BluetoothUUID.bit128(SwiftFoundation.UUID(rawValue: "4114F59A-39CF-4F28-AD00-0EA29E4103E2")!)
        
        public var value: SwiftFoundation.UUID
        
        public init(value: SwiftFoundation.UUID) {
            
            self.value = value
        }
        
        public init?(bigEndian: Data) {
            
            let byteValue = isBigEndian ? bigEndian.bytes : bigEndian.bytes.reversed()
            
            guard let value = SwiftFoundation.UUID(data: Data(bytes: byteValue))
                else { return nil }
            
            self.value = value
        }
        
        public func toBigEndian() -> Data {
            
            let bytes = isBigEndian ? value.toData().bytes : value.toData().bytes.reversed()
            
            return Data(bytes: bytes)
        }
    }
    
    /// The LED status. (1 byte) (read-write)
    public struct Status: GATTProfileCharacteristic {
        
        public static let length = 1
        
        public static let UUID = BluetoothUUID.bit128(SwiftFoundation.UUID(rawValue: "1801A456-100D-4CD2-B0CA-6EA30D4B1261")!)
        
        public var value: BluetoothBool
        
        public init(value: Bool = false) {
            
            self.value = BluetoothBool(value)
        }
        
        public init?(bigEndian: Data) {
            
            guard let byte = bigEndian.bytes.first,
                bigEndian.bytes.count == 1,
                let value = BluetoothBool(rawValue: byte)
                else { return nil }
            
            self.value = value
        }
        
        public func toBigEndian() -> Data {
            
            return Data(bytes: [value.rawValue])
        }
    }
}
