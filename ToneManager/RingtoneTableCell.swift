//
//  RingtoneTableCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// <#Description#>
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
    
    /// <#Description#>
    var ringtoneItem : Ringtone? = nil
    
    
    /// <#Description#>
    ///
    /// - Parameter state: <#state description#>
    public func updateButtons(_ state: Bool) -> Void {
        if state == true {
            self.playButton.alpha = 0.7
            self.playButton.isEnabled = true
            
            self.infoButton.alpha = 0.7
            self.infoButton.isEnabled = true
        } else {
            self.playButton.alpha = 0.0
            self.playButton.isEnabled = false
            
            self.infoButton.alpha = 0.0
            self.infoButton.isEnabled = false
        }
    }
    
    override public func prepareForReuse() {
        nameLabel.text = ""
        fromAppLabel.text = ""
        lengthLabel.text = ""
        installedLabel.text = ""
        ringtoneItem = nil
    }
}
