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
import MessageUI

/// View controller for main settings page
final class SettingsViewController : UITableViewController {
    
    //TODO: delete all ringtones action
    
    var ringtoneStore : RingtoneStore!
    
    /// Outlet for autoinstall UISwitch
    @IBOutlet public weak var autoInstallSwitch: UISwitch!
    
    
    required init?(coder aDecoder: NSCoder) {
        self.ringtoneStore = RingtoneStore.sharedInstance
        super.init(coder: aDecoder)
    }

    
    func updateUIStates() {
        autoInstallSwitch.isOn = Preferences.autoInstall
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

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            BFLog("Mail cancelled")
        case .saved:
            BFLog("Mail saved")
        case .sent:
            BFLog("Mail sent")
        case .failed:
            BFLog("Mail sent failure: %@", (error as NSError?) ?? "nil")
        }
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
            let version = Preferences.version
            let build = String(Preferences.build)
            
            let footerText = super.tableView(tableView, titleForFooterInSection: section)
            
            return "ToneManager \(version)-\(build)\n" + footerText!
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
        BFLog("autoinstall changed, new value = %d", Preferences.autoInstall)
    }
}

//MARK: Button Actions
extension SettingsViewController {
    @IBAction func sendEmailTapped(_ sender: UITapGestureRecognizer) {
        BFLog("Send email tapped, device")
        
        let identifier = deviceModel()
        let os = ProcessInfo().operatingSystemVersion
        let osString = String(os.majorVersion) + "." + String(os.minorVersion) + "." + String(os.patchVersion)
        let appVersion = "\(Preferences.version)-\(Preferences.build)"
        
        let importedTones = try? Data(contentsOf: plistURL)

        let settingsData = allSettingsAsData()
        
        let emailTitle = "[ToneManager \(appVersion)] Email from App"
        let messageBody = "\n\nDevice: \(identifier), iOS \(osString)\nApp Version: \(appVersion)\n\nFeature request or bug report?"
        let toRecipents = ["jesper@flodin.fi"]
        let mc: MFMailComposeViewController = MFMailComposeViewController()
        
        mc.mailComposeDelegate = self
        mc.setSubject(emailTitle)
        mc.setMessageBody(messageBody, isHTML: false)
        mc.addAttachmentData(installedPackages(), mimeType: "text/plain", fileName: "dpkgl.txt")
        if let tonesplist = importedTones {
            mc.addAttachmentData(tonesplist, mimeType: "text/plain", fileName: "tones.plist")
        }
        if let settingsDataNotNil = settingsData {
            mc.addAttachmentData(settingsDataNotNil, mimeType: "text/plain", fileName: "settings.plist")
        }
        mc.setToRecipients(toRecipents)
        
        present(mc, animated: true, completion: nil)
    }
    
    fileprivate func deviceModel() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    fileprivate func installedPackages() -> Data {
        let task = NSTask()
        task.setLaunchPath("/bin/sh")
        task.setArguments(["-c","dpkg -l"])
        let pipe = Pipe()
        task.setStandardOutput(pipe)
        task.launch()
        return pipe.fileHandleForReading.readDataToEndOfFile()
    }
    
    fileprivate func allSettingsAsData() -> Data? {
        var prefs = UserDefaults.standard.dictionaryRepresentation()
        if prefs.count < 1 { return nil }
        prefs.updateValue(UIDevice.current.name, forKey: "DeviceName") //include devicename for identifying device in BugFender
        let data = try? PropertyListSerialization.data(fromPropertyList: prefs, format: .xml, options: 0)
        return data
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
        openSafariVC(withUrl: "https://www.paypal.me/JesperGustavIsak")
    }
    
    /// Opens my twitter
    ///
    /// - Parameter sender: Gesture recognizer that called this function
    @IBAction public func twitterTapped(_ sender: UITapGestureRecognizer) {
        openSafariVC(withUrl: "https://twitter.com/JesperFlodin")
    }
}
