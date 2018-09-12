//
//  SettingsRingtoneAppsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-11.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

public class SettingsRingtoneAppsViewController : UITableViewController {
    
    let defaults = UserDefaults.standard
    
    @IBOutlet public weak var zedgeSwitch: UISwitch!
    @IBOutlet public weak var audikoLiteSwitch: UISwitch!
    @IBOutlet public weak var audikoProSwitch: UISwitch!
    
    public var zedge : Bool {
        get {
            return defaults.bool(forKey: "ZedgeRingtones")
        }
        set {
            defaults.set(newValue, forKey: "ZedgeRingtones")
        }
    }
    public var audikoLite : Bool {
        get {
            return defaults.bool(forKey: "AudikoLite")
        }
        set {
            defaults.set(newValue, forKey: "AudikoLite")
        }
    }
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
