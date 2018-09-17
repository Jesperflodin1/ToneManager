//
//  SettingsRingtoneAppsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-11.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// View controller used in settings which shows switches for default supported ringtone apps
final class SettingsRingtoneAppsViewController : UITableViewController {
    
    /// Outlet for UISwitch for Zedge Ringtones
    @IBOutlet weak var zedgeSwitch: UISwitch!
    /// Outlet for UISwitch for Audiko Lite
    @IBOutlet weak var audikoLiteSwitch: UISwitch!
    /// Outlet for UISwitch for Audiko Pro
    @IBOutlet weak var audikoProSwitch: UISwitch!
    
}

//MARK: Switches actions
extension SettingsRingtoneAppsViewController {
    /// Zedge Ringtones switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction public func zedgeChanged(_ sender: UISwitch) {
        Preferences.zedgeRingtones = sender.isOn
    }
    
    /// Audiko Lite switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction public func audikoLiteChanged(_ sender: UISwitch) {
        Preferences.audikoLite = sender.isOn
    }
    
    /// Audiko Pro switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction public func audikoProChanged(_ sender: UISwitch) {
        Preferences.audikoPro = sender.isOn
    }
}

//MARK: UIViewController override methods
extension SettingsRingtoneAppsViewController {
    /// Called when view will appear on screen. Reads preferences from userdefaults and sets user controls in this view
    ///
    /// - Parameter animated: true if view will appear with animation
    override public func viewWillAppear(_ animated: Bool) {
        
        if Preferences.zedgeRingtonesInstalled {
            zedgeSwitch.isEnabled = true
        } else {
            zedgeSwitch.isEnabled = false
            
        }
        
        if Preferences.audikoLiteInstalled {
            audikoLiteSwitch.isEnabled = true
        } else {
            audikoLiteSwitch.isEnabled = false
        }
        
        if Preferences.audikoProInstalled {
            audikoProSwitch.isEnabled = true
        } else {
            audikoProSwitch.isEnabled = false
        }
        zedgeSwitch.isOn = Preferences.zedgeRingtones
        audikoLiteSwitch.isOn = Preferences.audikoLite
        audikoProSwitch.isOn = Preferences.audikoPro
        super.viewWillAppear(animated)
    }
}
