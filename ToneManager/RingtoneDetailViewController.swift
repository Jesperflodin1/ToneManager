//
//  RingtoneDetailViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-08.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// View controller that shows details page for ringtone
public class RingtoneDetailViewController : UITableViewController {
    
    /// <#Description#>
    @IBOutlet public weak var nameLabel: UILabel!
    /// <#Description#>
    @IBOutlet public weak var appLabel: UILabel!
    /// <#Description#>
    @IBOutlet public weak var lengthLabel: UILabel!
    /// <#Description#>
    @IBOutlet public weak var sizeLabel: UILabel!
    /// <#Description#>
    @IBOutlet public weak var pathLabel: UILabel!
    
    
    /// Associated ringtone object to show in this view
    public var ringtone : Ringtone!
    
    
    /// Called when view will appear. Prepares outlets with values from associated ringtone object
    ///
    /// - Parameter animated: <#animated description#>
    override public func viewWillAppear(_ animated: Bool) {
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
