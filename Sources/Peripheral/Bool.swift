//
//  Bool.swift
//  
//
//  Created by Alsey Coleman Miller on 4/16/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

import SwiftFoundation

/// Boolean value that can be transmitted over Bluetooth GATT.
public struct BluetoothBool: ExpressibleByBooleanLiteral {
    
    public var boolValue: Bool
    
    public init(booleanLiteral value: Bool) {
        
        self.boolValue = value
    }
    
    public init(_ boolValue: Bool) {
        
        self.boolValue = boolValue
    }
}

extension BluetoothBool: RawRepresentable {
    
    public init?(rawValue: UInt8) {
        
        switch rawValue {
        case 0x00: self.boolValue = false
        case 0x01: self.boolValue = true
        default: return nil
        }
    }
    
    public var rawValue: UInt8 {
        
        if boolValue {
            
            return 0x01
            
        } else {
            
            return 0x00
        }
    }
}

extension BluetoothBool: DataConvertible {
    
    public init?(data: Data) {
        
        guard data.bytes.count == 1
            else { return nil }
        
        self.init(rawValue: data.bytes[0])
    }
    
    public func toData() -> Data {
        
        return Data(bytes: [rawValue])
    }
}
