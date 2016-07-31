//
//  BeaconController.swift
//
//
//  Created by Alsey Coleman Miller on 6/12/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

import SwiftFoundation
import CoreLocation

final class BeaconController: NSObject, CLLocationManagerDelegate {
    
    static let shared = BeaconController()
    
    // MARK: - Properties
    
    static let region: CLBeaconRegion = {
        
        let region = CLBeaconRegion(proximityUUID: BeaconUUID, major: 0, minor: 0, identifier: BeaconIdentifier)
        
        region.notifyEntryStateOnDisplay = true
        
        return region
    }()
    
    var log: ((String) -> ())?
    
    private(set) var regionState: CLRegionState = .unknown
    
    private lazy var locationManager: CLLocationManager = {
        
        let location = CLLocationManager()
        
        location.delegate = self
        
        return location
    }()
    
    // MARK: - Methods
    
    /// Starts monitoring.
    func start() {
        
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startMonitoring(for: BeaconController.region)
    }
    
    func stop() {
        
        locationManager.stopMonitoring(for: BeaconController.region)
    }
    
    // MARK: - CLLocationManagerDelegate
    
    @objc(locationManager:didStartMonitoringForRegion:)
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        log?("Started iBeacon monitoring")
    }
    
    @objc(locationManager:monitoringDidFailForRegion:withError:)
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
        log?("Could not start iBeacon monitoring. (\(error))")
    }
    
    @objc(locationManager:didDetermineState:forRegion:)
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        guard regionState != state else {
            
            log?("Region state: \(state.rawValue)")
            
            return
        }
        
        log?("Region state changed: \(state.rawValue)")
        
        // state changed
        regionState = state
    }
}

// MARK: - Private

let BeaconIdentifier = "Beacon"
