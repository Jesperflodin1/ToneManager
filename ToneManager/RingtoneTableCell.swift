//
//  RingtoneTableCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// UITableCell subclass for ringtones, used in ’RingtoneTableViewController’
public class RingtoneTableCell : UITableViewCell {
    /// Outlet for name label UILabel
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Outlet for label showing which app ringtone was imported from
    @IBOutlet weak var fromAppLabel: UILabel!
    
    /// Outlet for ringtone length label
    @IBOutlet weak var lengthLabel: UILabel!
    
    /// Outlet for label showing install status
    @IBOutlet weak var installedLabel: UILabel!
    
    
    /// Outlet for UIButton with play/pause action
    @IBOutlet weak var playButton: UIButton!
    
    /// Outlet for "more info", segues to ’RingtoneDetailViewController’ on tap
    @IBOutlet weak var infoButton: UIButton!
    
    /// Outlet for install button. Installs or uninstalls ringtone on tap
    @IBOutlet weak var installButton: UIButton!
    
    /// Outlet for trash button. Deletes ringtone
    @IBOutlet weak var deleteButton: UIButton!
    
    /// Outlet for install button constraint to the button left of it
    @IBOutlet weak var installButtonHorizontalConstraint: NSLayoutConstraint!
    
    /// Associated ringtone object
    var ringtoneItem : Ringtone? = nil
    
    
    /// Updates state of buttons (hidden/shown)
    ///
    /// - Parameter state: Bool, true for shown and false for hidden
    public func updateButtons(_ state: Bool) {
        if state == true {
            self.playButton.alpha = 0.7
            self.playButton.isEnabled = true
            
            self.infoButton.alpha = 0.7
            self.infoButton.isEnabled = true
            
            self.installButton.alpha = 0.7
            self.installButton.isEnabled = true
            
            self.deleteButton.alpha = 0.7
            self.deleteButton.isEnabled = true
            
            self.lengthLabel.alpha = 1.0
            self.lengthLabel.isHidden = false
        } else {
            self.playButton.alpha = 0.0
            self.playButton.isEnabled = false
            
            self.infoButton.alpha = 0.0
            self.infoButton.isEnabled = false
            
            self.installButton.alpha = 0.0
            self.installButton.isEnabled = false
            
            self.deleteButton.alpha = 0.0
            self.deleteButton.isEnabled = false
            
            self.lengthLabel.alpha = 0.0
            self.lengthLabel.isHidden = true
        }
    }
    
    /// Updates UIImage for install button to show if button action is install or uninstall. Also updates installed label
    public func updateInstallStatus() {
        if ringtoneItem?.identifier == nil { // not installed
            installButton.setImage(UIImage(named: "file-export"), for: .normal)
            installButtonHorizontalConstraint.constant = 20
            installedLabel.isHidden = true
            self.layoutIfNeeded()
        } else { // installed
            installButton.setImage(UIImage(named: "file-minus"), for: .normal)
            installButtonHorizontalConstraint.constant = 28
            installedLabel.isHidden = false
            self.layoutIfNeeded()
        }
    }
    
    /// UITableViewCell function which prepares cell for reuse
    override public func prepareForReuse() {
        nameLabel.text = ""
        fromAppLabel.text = ""
        lengthLabel.text = ""
        installedLabel.text = ""
        ringtoneItem = nil
    }
}
