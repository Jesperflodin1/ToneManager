//
//  RingtoneDetailViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-08.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class RingtoneDetailViewController : UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var appLabel: UILabel!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var pathLabel: UILabel!
    
    
    var ringtone : Ringtone!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        playButton.setImage(UIImage(named: "play-circle"), for: .normal)
//        playButton.contentVerticalAlignment = .fill
//        playButton.contentHorizontalAlignment = .fill
        if ringtone != nil {
            self.nameLabel.text = ringtone.name
            self.appLabel.text = ringtone.appName
            self.lengthLabel.text = "\(ringtone.totalTime)" // TODO: NumberFormatter
            self.sizeLabel.text = "\(ringtone.size)"
            self.pathLabel.text = ringtone.fileURL.path
        }
    }
    
}
