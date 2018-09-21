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
    
    var tabView : UITableView = UITableView()
    var appNames : [String] = []
    var theApps : [String:String] = [:]
    
    private var dataSource : AppListViewDataSource
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = dataSource
        dataSource.tableView = self.tableView
        
        
        guard let _ : AnyClass = NSClassFromString("ALApplicationList") else {
            errorAlert("Failed to load AppList. Is AppList really installed?")
            return
        }
        guard (ALApplicationList.shared()) != nil else {
            errorAlert("Error occured when loading apps with AppList.")
            return
        }
        
        
        
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
    
    
    /// Init method that gets called when storyboard initiates this view controller
    ///
    /// - Parameter aDecoder: not used here
    required public init?(coder aDecoder: NSCoder) {
        dataSource = AppListViewDataSource(WithController: self)
        
        let iconSize = NSNumber(value: ALApplicationIconSizeSmall)
        dataSource.sectionDescriptors = [
            [ALSectionDescriptorTitleKey:"User Applications",
             ALSectionDescriptorPredicateKey:"isSystemApplication = FALSE",
             ALSectionDescriptorCellClassNameKey:"ALSwitchCell",
             ALSectionDescriptorIconSizeKey:iconSize,
             ALSectionDescriptorSuppressHiddenAppsKey:kCFBooleanTrue],
            [ALSectionDescriptorTitleKey:"System Applications",
             ALSectionDescriptorPredicateKey:"isSystemApplication = TRUE",
             ALSectionDescriptorCellClassNameKey:"ALSwitchCell",
             ALSectionDescriptorIconSizeKey:iconSize,
             ALSectionDescriptorSuppressHiddenAppsKey:kCFBooleanTrue]
            ]
//        dataSource.sectionDescriptors = ALApplicationTableDataSource.standardSectionDescriptors()
        super.init(coder: aDecoder)
    }
    
    func value(ForCellAtIndexPath indexPath : IndexPath) -> Any {
        let cellDescriptor = dataSource.cellDescriptor(for: indexPath)
        if let cellDescript = cellDescriptor as? NSDictionary {
            
        }
    }
    
    
}
