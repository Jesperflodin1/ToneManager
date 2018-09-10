//
//  RingtoneTableCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class RingtoneTableCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var fromAppLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    
    @IBOutlet weak var installedLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    
    var ringtoneItem : Ringtone? = nil
    
    
    func updateButtons(_ state: Bool) -> Void {
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
}
