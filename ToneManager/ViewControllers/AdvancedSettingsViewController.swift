//
//  AdvancedSettingsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-21.
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
import PKHUD

final class AdvancedSettingsViewController : UITableViewController {
    /// Outlet for remote logging UISwitch
    @IBOutlet public weak var remoteLoggingSwitch: UISwitch!
    
    @IBOutlet weak var recursiveScanSwitch: UISwitch!
    
}

extension AdvancedSettingsViewController {
    override func viewWillAppear(_ animated: Bool) {
        remoteLoggingSwitch.isOn = Preferences.remoteLogging
        recursiveScanSwitch.isOn = Preferences.scanRecursively
        super.viewWillAppear(animated)
    }
}

extension AdvancedSettingsViewController {
    /// Remote logging switch changed state. Saves state to userdefaults
    ///
    /// - Parameter sender: UISwitch that initiated this
    @IBAction public func remoteLoggingChanged(_ sender: UISwitch) {
        Preferences.remoteLogging = sender.isOn
    }
    @IBAction func recursiveScanChanged(_ sender: UISwitch) {
        Preferences.scanRecursively = sender.isOn
    }
    @IBAction func deleteAllTapped(_ sender: UITapGestureRecognizer) {
        RingtoneManager.deleteAllRingtones(withAlert: true) {
            NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
        }
    }
    @IBAction func resetSettingsTapped(_ sender: UITapGestureRecognizer) {
        Preferences.reset()
        HUD.allowsInteraction = true
        HUD.flash(.label("Settings are now reset to defaults"), delay: 1.0)
    }
}
