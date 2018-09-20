//
//  SettingsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK
import SafariServices
import PKHUD

/// View controller for main settings page
final class SettingsViewController : UITableViewController {
    
    //TODO: delete all ringtones action
    
    var ringtoneStore : RingtoneStore!
    
    /// Outlet for autoinstall UISwitch
    @IBOutlet public weak var autoInstallSwitch: UISwitch!
    /// Outlet for remote logging UISwitch
    @IBOutlet public weak var remoteLoggingSwitch: UISwitch!
    
    required init?(coder aDecoder: NSCoder) {
        self.ringtoneStore = RingtoneStore.sharedInstance
        super.init(coder: aDecoder)
    }
    @IBAction func deleteAllTapped(_ sender: UITapGestureRecognizer) {
    }
    @IBAction func resetSettingsTapped(_ sender: UITapGestureRecognizer) {
        Preferences.reset()
        updateUIStates()
        HUD.allowsInteraction = true
        HUD.flash(.label("Settings are now reset to defaults"), delay: 1.0)
    }
    
    func updateUIStates() {
        autoInstallSwitch.isOn = Preferences.autoInstall
        remoteLoggingSwitch.isOn = Preferences.remoteLogging
    }
}

//MARK: SFSafariViewController methods
extension SettingsViewController: SFSafariViewControllerDelegate {
    /// Opens url in a SFSafariViewController
    ///
    /// - Parameter url: url to open
    public func openSafariVC(withUrl url : String) {
        
        let safariVC = SFSafariViewController(url: NSURL(string: url)! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    /// SFSafariViewControllerDelegate method. Called when user taps "done". Dismisses the safari window.
    ///
    /// - Parameter controller: SFSafariViewController this was initiated from.
    public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: UIViewController overrides
extension SettingsViewController {
    /// Called when view will appear on screen. Reads preferences from userdefaults and sets user controls in this view
    ///
    /// - Parameter animated: true if view will appear with animation
    override public func viewWillAppear(_ animated: Bool) {

        updateUIStates()
        super.viewWillAppear(animated)
    }
}

//MARK: UITableViewController DataSource methods
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section != 3 {
            return super.tableView(tableView, titleForFooterInSection: section)
        } else {
            let version : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
            let build : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
            
            let footerText = super.tableView(tableView, titleForFooterInSection: section)
            
            guard let versionString = version, let buildString = build else {
                return footerText!
            }
            return "ToneManager \(versionString)-\(buildString)\n" + footerText!
        }
    }
}

//MARK: Switches actions
extension SettingsViewController {
    /// Auto install ringtones switch changed state. Saves state to userdefaults
    ///
    /// - Parameter sender: UISwitch that initiated this
    @IBAction public func autoInstallChanged(_ sender: UISwitch) {
        Preferences.autoInstall = sender.isOn
        BFLog("autoScan changed, new value = \(Preferences.autoInstall)")
    }
    
    /// Remote logging switch changed state. Saves state to userdefaults
    ///
    /// - Parameter sender: UISwitch that initiated this
    @IBAction public func remoteLoggingChanged(_ sender: UISwitch) {
        Preferences.remoteLogging = sender.isOn
    }
}

//MARK: Button Actions
extension SettingsViewController {
    
    /// Opens github page
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction public func githubTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://github.com/Jesperflodin1/ToneManager")
    }
    
    /// Opens my reddit page
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction public func redditTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://www.reddit.com/user/jesperflodin1")
    }
    
    /// Opens paypal.me page for donations
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction public func paypalTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://www.paypal.me/Jesperflodin")
    }
    
    /// Opens my twitter
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction public func twitterTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://twitter.com/JesperFlodin")
    }
}
