//
//  RingtoneDetailViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-08.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// View controller that shows details page for ringtone
class RingtoneDetailViewController : UITableViewController {
    
    /// Outlet for ringtone name label
    @IBOutlet weak var nameLabel: UILabel!
    /// Outlet for label that show which app it was imported from.
    @IBOutlet weak var appLabel: UILabel!
    /// Outlet for ringtone length label
    @IBOutlet weak var lengthLabel: UILabel!
    /// Outlet for file size label
    @IBOutlet weak var sizeLabel: UILabel!
    /// Outlet for ringtone path label
    @IBOutlet weak var pathLabel: UILabel!
    
    /// Outlet for duration label in ringtone player
    @IBOutlet weak var ringtonePlayerDurationLabel: UILabel!
    
    /// Outlet for image left of play label
    @IBOutlet weak var ringtonePlayerPlayImage: UIImageView!
    
    /// Outlet for play label
    @IBOutlet weak var ringtonePlayerPlayLabel: UILabel!
    
    /// Associated ringtone object to show in this view
    var ringtone : Ringtone!
    
    /// Ringtoneplayer object used for playing ringtone
    var ringtonePlayer : RingtonePlayer?
    
    
    /// Called when view will appear. Prepares outlets with values from associated ringtone object
    ///
    /// - Parameter animated: true if view will appear with animation
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
            
            self.ringtonePlayerDurationLabel.text = "0 / \(ringtone.totalTime) s"
            
            super.viewWillAppear(animated)
        }
    }
    
    /// Overrides view will disappear, called when view will disappear. Stops playing ringtone.
    ///
    /// - Parameter animated: true if view will disappear with animation
    override func viewWillDisappear(_ animated: Bool) {
        if let player = self.ringtonePlayer {
            player.stopPlaying()
            self.ringtonePlayer = nil
        }
        
        super.viewWillDisappear(animated)
    }
    
    
    /// Called when play row is tapped in the associated tableview
    ///
    /// - Parameter sender: UITapGestureRecognizer that initiated this call
    @IBAction func playRowTapped(_ sender: UITapGestureRecognizer) {
        if self.ringtonePlayer == nil {
            self.ringtonePlayer = RingtonePlayer(ringtone: ringtone)
        }
        guard let player = ringtonePlayer else {
            return
        }
        
        if !player.isPlaying {
            ringtonePlayerPlayLabel.text = "Pause"
            ringtonePlayerPlayImage.image = UIImage(named: "pause-circle")
        } else {
            ringtonePlayerPlayLabel.text = "Play"
            ringtonePlayerPlayImage.image = UIImage(named: "play-circle")
        }
        
    }
    
}
