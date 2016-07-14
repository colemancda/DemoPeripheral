//
//  PeripheralsViewController.swift
//  DemoPeripheral
//
//  Created by Alsey Coleman Miller on 7/13/16.
//  Copyright © 2016 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit
import SwiftFoundation
import GATT

final class PeripheralsViewController: UITableViewController {
    
    // MARK: - Loading
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scan()
    }
    
    // MARK: - Actions
    
    @IBAction func scan(_ sender: AnyObject? = nil) {
        
        
    }
}

// MARK: - Supporting Types

final class PeripheralTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "PeripheralTableViewCell"
    
    @IBOutlet weak var peripheralLabel: UILabel!
    
    @IBOutlet weak var peripheralSwitch: UISwitch!
}
