//
//  RingtoneTableCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// UITableCell subclass for ringtones, used in ’RingtoneTableViewController’
final class RingtoneTableCell: UITableViewCell {
    /// Outlet for name label UILabel
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Outlet for label showing which app ringtone was imported from
    @IBOutlet weak var fromAppLabel: UILabel!
    
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
}

//MARK: Cell UIView update actions
extension RingtoneTableCell {
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
            
        } else {
            self.playButton.alpha = 0.0
            self.playButton.isEnabled = false
            
            self.infoButton.alpha = 0.0
            self.infoButton.isEnabled = false
            
            self.installButton.alpha = 0.0
            self.installButton.isEnabled = false
            
            self.deleteButton.alpha = 0.0
            self.deleteButton.isEnabled = false
        }
    }
    
    /// Updates UIImage for install button to show if button action is install or uninstall. Also updates installed label
    public func updateInstallStatus() {
        if !(ringtoneItem?.installed)! { // not installed
            installButton.setImage(ColorPalette.ringtoneCellInstallImage, for: .normal)
            installedLabel.isHidden = true
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } else { // installed
            installButton.setImage(ColorPalette.ringtoneCellUninstallImage, for: .normal)
            installedLabel.isHidden = false
            
            installedLabel.text = "Installed"
            installedLabel.backgroundColor = ColorPalette.backgroundColor
            installedLabel.layer.masksToBounds = true
            installedLabel.layer.borderColor = ColorPalette.themeColor.cgColor
            installedLabel.layer.borderWidth = 1
            installedLabel.layer.cornerRadius = 6
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}

//MARK: UITableViewCell override methods
extension RingtoneTableCell {
    /// UITableViewCell function which prepares cell for reuse
    override public func prepareForReuse() {
        nameLabel.text = ""
        fromAppLabel.text = ""
        installedLabel.text = ""
        updateButtons(false)
        ringtoneItem = nil
    }
}
