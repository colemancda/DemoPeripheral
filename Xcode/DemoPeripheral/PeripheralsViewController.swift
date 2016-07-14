//
//  PeripheralsViewController.swift
//  DemoPeripheral
//
//  Created by Alsey Coleman Miller on 7/13/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import SwiftFoundation
import GATT
import JGProgressHUD

/// Displays a list of nearby Demo peripherals.
final class PeripheralsViewController: UITableViewController {
    
    // MARK: - Properties
    
    private(set) var state: State = .scanning {
        
        didSet { updateUI() }
    }
    
    // MARK: - Private Properties
    
    private let progressHUD = JGProgressHUD(style: .dark)!
    
    private var progressHUDVisible = false
    
    private var stateObserver: Int!
    
    private var devicesObserver: Int!
    
    private var scanningObserver: Int!
    
    // MARK: - Loading
    
    deinit {
        
        // stop observing state
        PeripheralManager.shared.state.remove(observer: stateObserver)
        PeripheralManager.shared.foundDevices.remove(observer: devicesObserver)
        PeripheralManager.shared.scanning.remove(observer: scanningObserver)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start observing state
        stateObserver = PeripheralManager.shared.state.observe(stateChanged)
        devicesObserver = PeripheralManager.shared.foundDevices.observe(foundDevices)
        scanningObserver = PeripheralManager.shared.scanning.observe(scanningStateChanged)
        
        // start scanning
        if PeripheralManager.shared.state.value == .poweredOn {
            
            self.scan()
            
        } else {
            
            self.state = .error(Error.bluetoothDisabled)
        }
    }
    
    // MARK: - Actions
    
    @IBAction func scan(_ sender: AnyObject? = nil) {
        
        // dont scan if already scanning
        guard PeripheralManager.shared.scanning.value == false
            && PeripheralManager.shared.state.value == .poweredOn
            else { return }
        
        state = .scanning
        
        async { [weak self] in
            
            guard let controller = self else { return }
            
            do { try PeripheralManager.shared.scan(duration: 3) }
                
            catch { mainQueue { controller.state = .error(error) }; return }
            
            // callback will update UI
        }
    }
    
    @IBAction func toggleStatus(_ sender: UISwitch) {
        
        
    }
    
    // MARK: - Private Methods
    
    private func updateUI() {
        
        switch state {
            
        case .scanning:
            
            showProgressHUD()
            
        case let .error(error):
            
            dismissProgressHUD(animated: false)
            
            showErrorAlert("\(error)", okHandler: { self.scan() })
            
        case let .found(devices):
            
            assert(devices.isEmpty == false, "Should scan continously when there are no devices")
            
            dismissProgressHUD()
            
            tableView.reloadData()
        }
    }
    
    private func configure(cell: PeripheralTableViewCell, at indexPath: IndexPath) {
        
        guard case let .found(devices) = self.state else { fatalError("Invalid state: \(self.state)") }
        
        let device = devices[indexPath.row]
        
        cell.peripheralLabel.text = device.identifier.rawValue
        
        cell.peripheralSwitch.isOn = device.status
    }
    
    private func showProgressHUD() {
        
        guard progressHUDVisible == false else { return }
        
        tableView.reloadData()
        
        progressHUD.show(in: self.view)
        
        view.isUserInteractionEnabled = false
        
        progressHUDVisible = true
    }
    
    private func dismissProgressHUD(animated: Bool = true) {
        
        guard progressHUDVisible else { return }
        
        progressHUD.dismiss(animated: animated)
        
        view.isUserInteractionEnabled = true
        
        progressHUDVisible = false
    }
    
    // MARK: Peripheral Manager Notifications
    
    private func stateChanged(managerState: CBCentralManagerState) {
        
        mainQueue {
            
            // just powered on
            if managerState == .poweredOn {
                
                self.scan()
            }
                
            // bluetooth disabled
            else {
                
                self.state = .error(Error.bluetoothDisabled)
            }
        }
    }
    
    private func scanningStateChanged(isScanning: Bool) {
        
        if isScanning {
            
            mainQueue { self.state  = .scanning }
        }
    }
    
    private func foundDevices(devices: [PeripheralManager.Device]) {
        
        mainQueue {
            
            /// no devices were found
            guard devices.isEmpty == false else {
                
                self.scan()
                return
            }
            
            // display found peripherals
            mainQueue { self.state = .found(devices) }
        }
    }
    
    // MARK: -
    // MARK: UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard case .found = self.state else { return 0 }
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard case let .found(devices) = self.state else { return 0 }
        
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: PeripheralTableViewCell.reuseIdentifier, for: indexPath) as! PeripheralTableViewCell
        
        configure(cell: cell, at: indexPath)
        
        return cell
    }
}

// MARK: - Supporting Types

extension PeripheralsViewController {
    
    enum State {
        
        case scanning
        case error(ErrorProtocol)
        case found([PeripheralManager.Device])
    }
}

final class PeripheralTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PeripheralTableViewCell"
    
    @IBOutlet weak var peripheralLabel: UILabel!
    
    @IBOutlet weak var peripheralSwitch: UISwitch!
}
