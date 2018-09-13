//
//  SettingsRingtoneAppsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-11.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

/// View controller used in settings which shows switches for default supported ringtone apps
public class SettingsRingtoneAppsViewController : UITableViewController {
    
    /// Userdefaults object
    let defaults = UserDefaults.standard
    
    /// Outlet for UISwitch for Zedge Ringtones
    @IBOutlet weak var zedgeSwitch: UISwitch!
    /// Outlet for UISwitch for Audiko Lite
    @IBOutlet weak var audikoLiteSwitch: UISwitch!
    /// Outlet for UISwitch for Audiko Pro
    @IBOutlet weak var audikoProSwitch: UISwitch!
    
    /// Used to get and set "ZedgeRingtones" value in userdefaults
    public var zedge : Bool {
        get {
            return defaults.bool(forKey: "ZedgeRingtones")
        }
        set {
            defaults.set(newValue, forKey: "ZedgeRingtones")
        }
    }
    /// Used to get and set "AudikoLite" value in userdefaults
    public var audikoLite : Bool {
        get {
            return defaults.bool(forKey: "AudikoLite")
        }
        set {
            defaults.set(newValue, forKey: "AudikoLite")
        }
    }
    /// Used to get and set "AudikoPro" value in userdefaults
    public var audikoPro : Bool {
        get {
            return defaults.bool(forKey: "AudikoPro")
        }
        set {
            defaults.set(newValue, forKey: "AudikoPro")
        }
    }
    
    /// Zedge Ringtones switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction public func zedgeChanged(_ sender: UISwitch) {
        zedge = sender.isOn
    }
    
    /// Audiko Lite switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction public func audikoLiteChanged(_ sender: UISwitch) {
        audikoLite = sender.isOn
    }
    
    /// Audiko Pro switch changed state
    ///
    /// - Parameter sender: UISwitch that initiated this call
    @IBAction public func audikoProChanged(_ sender: UISwitch) {
        audikoPro = sender.isOn
    }
    
    /// Called when view will appear on screen. Reads preferences from userdefaults and sets user controls in this view
    ///
    /// - Parameter animated: true if view will appear with animation
    override public func viewWillAppear(_ animated: Bool) {
        zedgeSwitch.isOn = zedge
        audikoLiteSwitch.isOn = audikoLite
        audikoProSwitch.isOn = audikoPro
        super.viewWillAppear(animated)
    }
    
}
