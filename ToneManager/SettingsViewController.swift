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

/// View controller for main settings page
public class SettingsViewController : UITableViewController, SFSafariViewControllerDelegate {
    
    let defaults = UserDefaults.standard
    public var autoInstall : Bool {
        get {
            return defaults.bool(forKey: "AutoInstall")
        }
        set {
            defaults.set(newValue, forKey: "AutoInstall")
        }
    }
    public var remoteLogging : Bool {
        get {
            return defaults.bool(forKey: "RemoteLogging")
        }
        set {
            defaults.set(newValue, forKey: "RemoteLogging")
        }
    }
    
    @IBOutlet public weak var autoInstallSwitch: UISwitch!
    @IBOutlet public weak var remoteLoggingSwitch: UISwitch!
    
    /// Auto install ringtones switch changed state. Saves state to userdefaults
    ///
    /// - Parameter sender: UISwitch that initiated this
    @IBAction public func autoInstallChanged(_ sender: UISwitch) {
        autoInstall = sender.isOn
        BFLog("autoScan changed, new value = \(autoInstall)")
    }
    
    /// Remote logging switch changed state. Saves state to userdefaults
    ///
    /// - Parameter sender: UISwitch that initiated this
    @IBAction public func remoteLoggingChanged(_ sender: UISwitch) {
        remoteLogging = sender.isOn
    }

    /// Called when view will appear on screen. Reads preferences from userdefaults and sets user controls in this view
    ///
    /// - Parameter animated: true if view will appear with animation
    override public func viewWillAppear(_ animated: Bool) {
        BFLog("autoScan = \(autoInstall)")
        autoInstallSwitch.isOn = autoInstall
        remoteLoggingSwitch.isOn = remoteLogging
        super.viewWillAppear(animated)
    }
    
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
