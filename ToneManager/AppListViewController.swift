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

/// Table view controller that uses Applist to show list of apps
final class AppListViewController : UITableViewController {
    
    var appInfo : [String:String] = [:]
    

    
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
//        if Preferences.zedgeRingtones {
//            apps.append("com.zedge.Zedge")
//        }
//        if Preferences.audikoLite {
//            apps.append("com.908.AudikoFree")
//        }
//        if Preferences.audikoPro {
//            apps.append("com.908.Audiko")
        
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
            
            appInfo.updateValue(displayName, forKey: identifier)
        }
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
        
        
        
        cell.delegate = self
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
}

extension AppListViewController: AppListCellDelegate {
    
    func valueDidChange(_ value: Bool, appIdentifier: String) {
        <#code#>
    }
}
