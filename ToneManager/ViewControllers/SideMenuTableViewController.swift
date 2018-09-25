//
//  SideMenuTableViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-16.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import SideMenu
import StoreKit
import BugfenderSDK
import FileBrowser
import PKHUD

final class SideMenuTableViewController: UITableViewController {
    
    @IBOutlet weak var openZedgeLabel: UILabel!
    @IBOutlet weak var openAudikoLiteLabel: UILabel!
    @IBOutlet weak var openAudikoPaidLabel: UILabel!
    
    var cellHeight : CGFloat = 36
    var footerHeight : CGFloat = 10
    
    @IBAction func openPrefsTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        LSApplicationWorkspaceHandler.openSensitiveURL(URL(string: "prefs:root=Sounds"))
    }
    @IBAction func reloadRingtonesTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        RingtoneManager.updateRingtones {
            NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
        }
    }
    
    @IBAction func importFileTapped(_ sender: UITapGestureRecognizer) {

        let fileBrowser = FileBrowser(initialPath: URL(fileURLWithPath: Preferences.fileBrowserDefaultPath), allowEditing: false, showCancelButton: true)
        fileBrowser.excludesFileExtensions = Preferences.defaultExcludedFileExtensions
        
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            RingtoneManager.importRingtoneFile(file, onSuccess: {
                NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
            })
        }
        guard let topVC = UIApplication.topViewController() else { return }
        topVC.present(fileBrowser, animated: true, completion: nil)
    }
    
    @IBAction func openZedgeTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        if Preferences.zedgeRingtonesInstalled {
            if !LSApplicationWorkspaceHandler.openApplication(withBundleID: "com.zedge.Zedge") {
                Bugfender.error("Failed to open app with LSApplicationWorkspace")
            }
            
        } else {
            openAppStore(forApp: Preferences.zedgeItunesId)
        }
        
    }
    
    @IBAction func openAudikoLiteTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        if Preferences.audikoLiteInstalled {
            if !LSApplicationWorkspaceHandler.openApplication(withBundleID: "com.908.AudikoFree") {
                Bugfender.error("Failed to open app with LSApplicationWorkspace")
            }
        } else {
            openAppStore(forApp: Preferences.audikoLiteItunesId)
        }
        
    }
    
    @IBAction func openAudikoPaidTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        if Preferences.audikoProInstalled {
            if !LSApplicationWorkspaceHandler.openApplication(withBundleID: "com.908.Audiko")  {
                Bugfender.error("Failed to open app with LSApplicationWorkspace")
            }
        } else {
            openAppStore(forApp: Preferences.audikoProItunesId)
        }
        
    }
}

//MARK: UIViewController method override
extension SideMenuTableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !Preferences.zedgeRingtonesInstalled {
            openZedgeLabel.text = "Install Zedge"
        }
        if !Preferences.audikoLiteInstalled {
            openAudikoLiteLabel.text = "Install Audiko Lite"
        }
        if !Preferences.audikoProInstalled {
            openAudikoPaidLabel.text = "Install Audiko Pro"
        }
        
        // refresh cell blur effect in case it changed
        tableView.reloadData()
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        guard SideMenuManager.default.menuBlurEffectStyle == nil else {
            return
        }
        
        
        
        // Set up a cool background image for demo purposes
        let imageView = UIImageView(image: ColorPalette.sideMenuBackground)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        tableView.backgroundView = imageView
    }
    
    override func viewDidLoad() {
        let bounds: CGRect = UIScreen.main.bounds
        let height = bounds.size.height
        
        if height < 500 { //4s
            cellHeight = 36
            footerHeight = 10
        } else if height < 600 { //5s, se
            cellHeight = 40
            footerHeight = 30
        } else if height < 700 { // 6s, 7, 8
            cellHeight = 44
            footerHeight = 60
        } else if height < 800 {
            cellHeight = 44
            footerHeight = 75
        } else {
            cellHeight = 44
            footerHeight = 75
        }
        tableView.reloadData()
        
    }
}

//MARK: App store methods (SKStoreProductViewControllerDelegate)
extension SideMenuTableViewController: SKStoreProductViewControllerDelegate {
    func openAppStore(forApp appid : NSNumber) {
        let storeKitVC = SKStoreProductViewController()
        storeKitVC.delegate = self
        storeKitVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : appid], completionBlock:
            { [weak self] (loaded, error) -> Void in
                if loaded {
                    // Parent class of self is UIViewContorller
                    self?.present(storeKitVC, animated: true, completion: nil)
                } })
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
}


//MARK: UITableView DataSource
extension SideMenuTableViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        
        cell.blurEffectStyle = SideMenuManager.default.menuBlurEffectStyle
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, indexPath.section == 0 {
            return 10
        } else {
            return cellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerHeight
    }
    
    
}
