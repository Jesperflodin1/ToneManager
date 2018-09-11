//
//  SettingsRingtoneAppsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-11.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class SettingsRingtoneAppsViewController : UITableViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var zedgeSwitch: UISwitch!
    @IBOutlet weak var audikoLiteSwitch: UISwitch!
    @IBOutlet weak var audikoProSwitch: UISwitch!
    
    /// Zedge Ringtones switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction func zedgeChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "ZedgeRingtones")
    }
    
    /// Audiko Lite switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction func audikoLiteChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "AudikoLite")
    }
    
    /// Audiko Pro switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction func audikoProChanged(_ sender: UISwitch) {
        defaults.set(sender.isOn, forKey: "AudikoPro")
    }
    
    /// Called when view will appear on screen. Reads preferences from userdefaults and sets user controls in this view
    ///
    /// - Parameter animated: true if view will appear with animation
    override func viewWillAppear(_ animated: Bool) {
        zedgeSwitch.isOn = defaults.bool(forKey: "ZedgeRingtones")
        audikoLiteSwitch.isOn = defaults.bool(forKey: "AudikoLite")
        audikoProSwitch.isOn = defaults.bool(forKey: "AudikoPro")
        super.viewWillAppear(animated)
    }
    
}
