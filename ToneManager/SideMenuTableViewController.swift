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
    
    @IBAction func reloadRingtonesTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        RingtoneManager.updateRingtones {
            NotificationCenter.default.post(name: .ringtoneStoreDidReload, object: nil)
        }
    }
    
    @IBAction func importFileTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        let fileBrowser = FileBrowser(initialPath: URL(fileURLWithPath: "/"), allowEditing: false, showCancelButton: true)
        fileBrowser.excludesFileExtensions = ["zip", "txt", "jpg", "jpeg", "png", "gif", "deb", "xml"]
        
        fileBrowser.didSelectFile = { (file: FBFile) -> Void in
            RingtoneStore.sharedInstance.importFile(file, completionHandler: { (success, error) in
                if !success {
                    guard let errorType = error else { return }
                    if errorType.code == ErrorCode.invalidRingtoneFile.rawValue {
                        HUD.flash(.labeledError(title: "Error", subtitle: "File is not a valid ringtone"), delay: 1.0)
                        return
                    } else {
                        
                        HUD.flash(.labeledSuccess(title: "Success", subtitle: "Imported 1 Ringtone"), delay: 0.7)
                        
                         NotificationCenter.default.post(name: .ringtoneStoreDidReload, object: nil)
                    }
                }
                
                
            })
        }
        present(fileBrowser, animated: true, completion: nil)
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
            openZedgeLabel.text = "Install Zedge Ringtones"
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
}
