//
//  ErrorAlert.swift
//
//  Created by Alsey Coleman Miller on 10/22/15.
//  Copyright © 2015 ColemanCDA. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    /** Presents an error alert controller with the specified completion handlers.  */
    func showErrorAlert(_ localizedText: String, okHandler: (() -> ())? = nil, retryHandler: (()-> ())? = nil) {
        
        let alert = UIAlertController(title: NSLocalizedString("Error", comment: "Error"),
            message: localizedText,
            preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.`default`, handler: { (UIAlertAction) in
            
            okHandler?()
            
            alert.dismiss(animated: true, completion: nil)
        }))
        
        // optionally add retry button
        
        if retryHandler != nil {
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Retry", comment: "Retry"), style: UIAlertActionStyle.`default`, handler: { (UIAlertAction) in
                
                retryHandler!()
                
                alert.dismiss(animated: true, completion: nil)
            }))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
}
