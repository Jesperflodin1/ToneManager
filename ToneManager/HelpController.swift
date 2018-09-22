//
//  HelpController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-22.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import PopupDialog

final class HelpController {
    
    /// Shows an alert with a back button that pops back to the latest view controller (settings)
    ///
    /// - Parameter message: Message to show in alert
    private class func showPopup(_ message : String) {
        
        let title = "Help"
        
        let popup = PopupDialog(title: title, message: message, image: ColorPalette.alertBackground)
        let buttonOne = DefaultButton(title: "Close", action: nil)
        
        popup.addButton(buttonOne)
        
        guard let topVC = UIApplication.topViewController() else { return }
        topVC.present(popup, animated: true, completion: nil)
    }
    
}
