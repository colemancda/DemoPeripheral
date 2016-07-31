//
//  Observable.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

public final class Observable<Value> {
    
    // MARK: - Properties
    
    public internal(set) var value: Value {
        
        didSet {
            
            for observer in observers {
                
                observer.callback(value)
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var observers = [Observer<Value>]()
    
    private var nextID = 1
    
    // MARK: - Initialization
    
    public init(_ value: Value) {
        
        self.value = value
    }
    
    // MARK: - Methods
    
    public func observe(_ observer: (Value) -> ()) -> Int {
        
        let identifier = nextID
        
        // create notification
        let observer = Observer(identifier: identifier, callback: observer)
        
        // increment ID
        nextID += 1
        
        // add to queue
        observers.append(observer)
        
        return identifier
    }
    
    @discardableResult
    public func remove(observer: Int) -> Bool {
        
        guard let index = observers.index(where: { $0.identifier == observer })
            else { return false }
        
        observers.remove(at: index)
        
        return true
    }
}

public extension Observable where Value: ExpressibleByNilLiteral {
    
    convenience init() { self.init(nil) }
}

private struct Observer<Value> {
    
    let identifier: Int
    
    let callback: (Value) -> ()
    
    init(identifier: Int, callback: (Value) -> ()) {
        
        self.identifier = identifier
        self.callback = callback
    }
}
