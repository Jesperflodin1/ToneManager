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

class SideMenuTableViewController: UITableViewController, SKStoreProductViewControllerDelegate {
    
    @IBOutlet weak var openZedgeLabel: UILabel!
    @IBOutlet weak var openAudikoLiteLabel: UILabel!
    @IBOutlet weak var openAudikoPaidLabel: UILabel!
    
    let zedgeItunesId : NSNumber = 584485870
    let audikoLiteItunesId : NSNumber = 878910012
    let audikoProItunesId : NSNumber = 725401575
    
    @IBAction func openZedgeTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        if Preferences.zedgeRingtonesInstalled {
            ApplicationHandler.openApplication(withIdentifier: "com.zedge.Zedge")
        } else {
            openAppStore(forApp: zedgeItunesId)
        }
        
    }
    
    @IBAction func openAudikoLiteTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        if Preferences.audikoLiteInstalled {
            ApplicationHandler.openApplication(withIdentifier: "com.908.AudikoFree")
        } else {
            openAppStore(forApp: audikoLiteItunesId)
        }
        
    }
    
    @IBAction func openAudikoPaidTapped(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
        if Preferences.audikoProInstalled {
            ApplicationHandler.openApplication(withIdentifier: "com.908.Audiko")
        } else {
            openAppStore(forApp: audikoProItunesId)
        }
        
    }
    
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
        let imageView = UIImageView(image: UIImage(named: "menuBackground"))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        tableView.backgroundView = imageView
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! UITableViewVibrantCell
        
        cell.blurEffectStyle = SideMenuManager.default.menuBlurEffectStyle
        
        return cell
    }
    
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
