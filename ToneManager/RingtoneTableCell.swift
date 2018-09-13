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
    /// <#Description#>
    @IBOutlet weak var nameLabel: UILabel!
    /// <#Description#>
    @IBOutlet weak var fromAppLabel: UILabel!
    /// <#Description#>
    @IBOutlet weak var lengthLabel: UILabel!
    
    /// <#Description#>
    @IBOutlet weak var installedLabel: UILabel!
    
    /// <#Description#>
    @IBOutlet weak var playButton: UIButton!
    /// <#Description#>
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var installButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
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
            
            self.lengthLabel.alpha = 0.7
            self.lengthLabel.isHidden = false
        } else {
            self.playButton.alpha = 0.0
            self.playButton.isEnabled = false
            
            self.infoButton.alpha = 0.0
            self.infoButton.isEnabled = false
            
            self.installButton.alpha = 0.0
            self.installButton.isEnabled = false
            
            self.lengthLabel.alpha = 0.0
            self.lengthLabel.isHidden = true
        }
    }
    
    public func updateInstalledButton() {
        if ringtoneItem?.identifier == nil {
            installButton.setImage(UIImage(named: "file-export"), for: .normal)
        } else {
            installButton.setImage(UIImage(named: "file-minus"), for: .normal)
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
