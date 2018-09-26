//
//  SettingsRingtoneAppsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-11.
//
//
//  MIT License
//
//  Copyright (c) 2018 Jesper Flodin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

/// View controller used in settings which shows switches for default supported ringtone apps
final class SettingsRingtoneAppsViewController : UITableViewController {
    
    @IBOutlet weak var zedgeImage: UIImageView!
    @IBOutlet weak var audikoLiteImage: UIImageView!
    @IBOutlet weak var audikoProImage: UIImageView!
    
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
            zedgeImage.image = ALApplicationList.shared().icon(ofSize: UInt(ALApplicationIconSizeSmall), forDisplayIdentifier: Preferences.defaultApps[Preferences.keys.zedgeRingtones.rawValue]!)
        } else {
            zedgeSwitch.isEnabled = false
            
        }
        
        if Preferences.audikoLiteInstalled {
            audikoLiteSwitch.isEnabled = true
            audikoLiteImage.image = ALApplicationList.shared().icon(ofSize: UInt(ALApplicationIconSizeSmall), forDisplayIdentifier: Preferences.defaultApps[Preferences.keys.audikoLite.rawValue]!)
        } else {
            audikoLiteSwitch.isEnabled = false
        }
        
        if Preferences.audikoProInstalled {
            audikoProSwitch.isEnabled = true
            audikoProImage.image = ALApplicationList.shared().icon(ofSize: UInt(ALApplicationIconSizeSmall), forDisplayIdentifier: Preferences.defaultApps[Preferences.keys.audikoPro.rawValue]!)
        } else {
            audikoProSwitch.isEnabled = false
        }
        zedgeSwitch.isOn = Preferences.zedgeRingtones
        audikoLiteSwitch.isOn = Preferences.audikoLite
        audikoProSwitch.isOn = Preferences.audikoPro
        
        
        
        super.viewWillAppear(animated)
    }
}
