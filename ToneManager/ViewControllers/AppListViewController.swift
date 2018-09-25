//
//  AppListViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-11.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK
import PopupDialog
import PKHUD

/// Table view controller that uses Applist to show list of apps
final class AppListViewController : UITableViewController {
    
    var appInfo : [String:String] = [:]
    var appNames : [String] = []

    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        guard let _ : AnyClass = NSClassFromString("ALApplicationList") else {
            errorAlert("Failed to load AppList. Is AppList really installed?")
            return
        }
        guard let appList = ALApplicationList.shared() else {
            errorAlert("Error occured when loading apps with AppList.")
            return
        }
        
        let excludedApps = [
            "com.zedge.Zedge",
            "com.908.AudikoFree",
            "com.908.Audiko"]
        
        let apps = appList.applicationsFiltered(using: NSPredicate(format: "isSystemApplication = FALSE")) as! [String : String]
        
        for (identifier, displayName) in apps {
            if appList.application(withDisplayIdentifierIsHidden: identifier) {
                continue // skip hidden apps
            }
            if identifier == Bundle.main.bundleIdentifier { continue }
            if excludedApps.contains(identifier) { continue }
            
            if appNames.contains(displayName) { continue }
            
            appInfo.updateValue(displayName, forKey: identifier)
            appNames.append(displayName)
        }
        appNames = appNames.sorted(by: < )
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    /// Shows an alert with a back button that pops back to the latest view controller (settings)
    ///
    /// - Parameter message: Message to show in alert
    private func errorAlert(_ message : String) {
        
        let title = "AppList Error"

        let popup = PopupDialog(title: title, message: message, image: ColorPalette.alertBackground)
        let buttonOne = DefaultButton(title: "Back") { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.navigationController?.popViewController(animated: true)
            
        }
        
        popup.addButton(buttonOne)
        
        present(popup, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppListCell") as! AppListCell
        
        let appName = appNames[indexPath.row]
        let appIdentifier = appInfo.first { (arg0) -> Bool in
            let (_, value) = arg0
            return appName == value
        }?.key
        
        cell.appIdentifier = appIdentifier!
        cell.appName.text = appName
        cell.appImage.image = ALApplicationList.shared()?.icon(ofSize: UInt(ALApplicationIconSizeSmall), forDisplayIdentifier: appIdentifier)
        if Preferences.extraAppIsEnabled(appIdentifier!) {
            cell.appSwitch.isOn = true
        } else {
            cell.appSwitch.isOn = false
        }
        cell.delegate = self
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let cell = tableView.cellForRow(at: indexPath) as? AppListCell
//        HUD.allowsInteraction = true
//        HUD.flash(.label(cell?.appIdentifier), delay: 0.5)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appInfo.count
    }
    
    
    
}

extension AppListViewController: AppListCellDelegate {
    
    func valueDidChange(_ value: Bool, appIdentifier: String) {
        if value {
            Preferences.extraAppEnable(appIdentifier)
        } else {
            Preferences.extraAppDisable(appIdentifier)
        }
    }
}
