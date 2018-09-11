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

/// <#Description#>
class SettingsViewController : UITableViewController, SFSafariViewControllerDelegate {
    
    
    @IBOutlet weak var autoInstallSwitch: UISwitch!
    @IBOutlet weak var remoteLoggingSwitch: UISwitch!
    
    @IBAction func autoInstallChanged(_ sender: UISwitch) {
    }
    
    @IBAction func remoteLoggingChanged(_ sender: UISwitch) {
    }
    
    override func viewDidLoad() {
        <#code#>
    }
    
    /// Opens github page
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction func githubTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://github.com/Jesperflodin1/ToneManager")
    }

    /// Opens my reddit page
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction func redditTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://www.reddit.com/user/jesperflodin1")
    }
    
    /// Opens paypal.me page for donations
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction func paypalTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://www.paypal.me/Jesperflodin")
    }
    
    /// Opens my twitter
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction func twitterTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://twitter.com/JesperFlodin")
    }
    
    /// Opens url in a SFSafariViewController
    ///
    /// - Parameter url: url to open
    func openSafariVC(withUrl url : String) {
        
        let safariVC = SFSafariViewController(url: NSURL(string: url)! as URL)
        self.present(safariVC, animated: true, completion: nil)
        safariVC.delegate = self
    }
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
