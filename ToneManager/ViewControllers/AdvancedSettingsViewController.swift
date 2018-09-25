//
//  AdvancedSettingsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-21.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import PKHUD

final class AdvancedSettingsViewController : UITableViewController {
    /// Outlet for remote logging UISwitch
    @IBOutlet public weak var remoteLoggingSwitch: UISwitch!
    
}

extension AdvancedSettingsViewController {
    override func viewWillAppear(_ animated: Bool) {
        remoteLoggingSwitch.isOn = Preferences.remoteLogging
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
