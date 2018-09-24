//
//  AppListCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-21.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class AppListCell : UITableViewCell {
    
    @IBOutlet weak var appImage: UIImageView!
    @IBOutlet weak var appName: UILabel!
    @IBOutlet weak var appSwitch: UISwitch!
    
    weak var delegate : AppListCellDelegate!
    
    var appIdentifier : String!
    
    @IBAction func appSwitchChanged(_ sender: UISwitch) {
        delegate.valueDidChange(sender.isOn, appIdentifier: appIdentifier)
    }
    
}
