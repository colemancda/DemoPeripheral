//
//  Async.swift
//
//
//  Created by Alsey Coleman Miller on 6/12/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

import Foundation

func mainQueue(_ block: () -> ()) {
    
    OperationQueue.main().addOperation(block)
}

/// Perform a task on the internal queue.
@inline(__always)
func async(_ block: () -> ()) {
    
    queue.async { block() }
}

private let queue = DispatchQueue(label: "Internal App Queue", attributes: .serial)
