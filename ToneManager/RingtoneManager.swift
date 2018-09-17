//
//  RingtoneManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import PKHUD
import BugfenderSDK

class RingtoneManager {
  //  /// Storage for Ringtones
  //  fileprivate var ringtoneStore : RingtoneStore!
  //
  //  init() {
  //    ringtoneStore = RingtoneStore.sharedInstance
  //  }
}

//MARK: Update methods
extension RingtoneManager {
  /// Rescans apps to find new ringtones
  class func updateRingtones(onSuccess completionHandler: (() -> Void)? = nil) {
    
    //        HUD.show(.labeledProgress(title: "Updating", subtitle: "Scanning for new ringtones"))
    
    RingtoneStore.sharedInstance.updateRingtones { (needsUpdate: Bool)  in
      
      NSLog("updateringtones callback")
      if (needsUpdate) {
        NSLog("updateringtones callback, got true for needsupdate")
        HUD.allowsInteraction = true
        HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Updated available ringtones"), delay: 0.5)
        completionHandler?()
      }
    }
  }
}

//MARK: Install methods
extension RingtoneManager {
  
  class func installRingtone(inCell: RingtoneTableCell, onSuccess: (() -> Void)? = nil) {
    guard let ringtone = inCell.ringtoneItem else { return }
    
    let title = "Install \(ringtone.name)"
    let message = "Are you sure you want to add this ringtone to device ringtones?"
    let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    ac.addAction(cancelAction)
    
    let installAction = UIAlertAction(title: "Install", style: .default, handler: { (action) -> Void in
      RingtoneStore.sharedInstance.installRingtone(ringtone, completionHandler: { (installedRingtone, success) in
        if (success) {
          
          BFLog("Got success in callback from ringtone install")
          inCell.updateInstallStatus()
          HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed ringtone"), delay: 0.7)
          onSuccess?()
        } else {
          
          BFLog("Got failure in callback from ringtone install")
          HUD.flash(.labeledError(title: "Error", subtitle: "Error when installing ringtone"), delay: 0.7)
        }
      })
    })
    ac.addAction(installAction)
    
    guard let topVC = UIApplication.topViewController() else {
      Bugfender.error("Could not get top view controller when trying to display alert")
      return
    }
    topVC.present(ac, animated: true, completion: nil)
  }
  

  class func installAllRingtones(withAlert : Bool = true, onSuccess: (() -> Void)? = nil) {
    let toneCount = RingtoneStore.sharedInstance.notInstalledRingtones.count
    if toneCount == 0 {
      HUD.allowsInteraction = true
      HUD.flash(.label("All available ringtones are already installed"), delay: 1.0)
      return
    }
    
    if withAlert {
      
      let title = "Install all available ringtones"
      let message = "This will install \(toneCount) ringtones. Are you sure you want to continue?"
      let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      ac.addAction(cancelAction)
      
      let installAction = UIAlertAction(title: "Install All", style: .default, handler: { (action) -> Void in
        
        HUD.show(.labeledProgress(title: "Installing", subtitle: "Installing all ringtones"))
        
        BFLog("Calling install for all ringtones")
        
        RingtoneStore.sharedInstance.installAllRingtones(completionHandler: { (installedTones : Int, failedTones : Int) in
          
          if installedTones > 0, failedTones == 0 {
            HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones"), delay: 1.0)
          } else if installedTones > 0, failedTones > 0 {
            HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones, however \(failedTones) failed to install"), delay: 1.0)
          } else if installedTones == 0 {
            HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were imported because of an unknown error"), delay: 1.0)
          } else {
            HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
          }
          
          onSuccess?()
        })
        
      })
      ac.addAction(installAction)
      
      guard let topVC = UIApplication.topViewController() else {
        Bugfender.error("Could not get top view controller when trying to display alert")
        return
      }
      topVC.present(ac, animated: true, completion: nil)
    }
  }
}

//MARK: Uninstall methods
extension RingtoneManager {
  
  class func uninstallRingtone(inCell: RingtoneTableCell, onSuccess: (() -> Void)? = nil) {
    guard let ringtone = inCell.ringtoneItem else { return }
    
    let title = "Uninstall \(ringtone.name)"
    let message = "Are you sure you want to uninstall this ringtone?"
    let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    ac.addAction(cancelAction)
    
    let installAction = UIAlertAction(title: "Uninstall", style: .destructive, handler: { (action) -> Void in
      
      RingtoneStore.sharedInstance.uninstallRingtone(ringtone, completionHandler: { (success) in
        if success {
          inCell.updateInstallStatus()
          HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled ringtone"), delay: 0.7)
          onSuccess?()
        } else {
          HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when uninstalling ringtone"), delay: 1.0)
        }
      })
    })
    ac.addAction(installAction)
    
    guard let topVC = UIApplication.topViewController() else {
      Bugfender.error("Could not get top view controller when trying to display alert")
      return
    }
    topVC.present(ac, animated: true, completion: nil)
  }
  
  class func uninstallAll(withAlert : Bool = true, onSuccess: (() -> Void)? = nil) {
    let toneCount = RingtoneStore.sharedInstance.installedRingtones.count
    if toneCount == 0 {
      HUD.allowsInteraction = true
      HUD.flash(.label("No ringtones are installed"), delay: 1.0)
      return
    }
    
    if withAlert {
      
      let title = "Uninstall all installed ringtones"
      let message = "This will uninstall \(toneCount) ringtones. Are you sure you want to continue?"
      let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      ac.addAction(cancelAction)
      
      let installAction = UIAlertAction(title: "Uninstall All", style: .default, handler: { (action) -> Void in
        
        HUD.show(.labeledProgress(title: "Uninstalling", subtitle: "Uninstalling all ringtones"))
        
        BFLog("Calling uninstall for all ringtones")
        
        RingtoneStore.sharedInstance.uninstallAllRingtones(completionHandler: { (uninstalledTones : Int, failedTones : Int) in
          
          if uninstalledTones > 0, failedTones == 0 {
            HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled \(uninstalledTones) ringtones"), delay: 1.0)
          } else if uninstalledTones > 0, failedTones > 0 {
            HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled \(uninstalledTones) ringtones, however \(failedTones) failed to install"), delay: 1.0)
          } else if uninstalledTones == 0 {
            HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were uninstalled because of an unknown error"), delay: 1.0)
          } else {
            HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
          }
          
          onSuccess?()
        })
        
      })
      ac.addAction(installAction)
      guard let topVC = UIApplication.topViewController() else {
        Bugfender.error("Could not get top view controller when trying to display alert")
        return
      }
      topVC.present(ac, animated: true, completion: nil)
    }
  }
}

//MARK: Delete methods
extension RingtoneManager {
  
  class func deleteRingtone(inCell: RingtoneTableCell, onSuccess: (() -> Void)? = nil) {
    guard let ringtone = inCell.ringtoneItem else { return }
    
    let title = "Delete \(ringtone.name)"
    let message = "Are you sure you want to delete this ringtone from this app? It will also be removed from the devices ringtones if installed. If you do not remove it from the source app it will get imported again at next refresh."
    let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    ac.addAction(cancelAction)
    
    let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler:
    { (action) -> Void in
      RingtoneStore.sharedInstance.removeRingtone(ringtone, completion: { (success) in
        if success {
          
          HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted ringtone"), delay: 0.7)
        } else {
          HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when deletin ringtone"), delay: 1.0)
        }
        
        onSuccess?()
      })
    })
    ac.addAction(deleteAction)
    guard let topVC = UIApplication.topViewController() else {
      Bugfender.error("Could not get top view controller when trying to display alert")
      return
    }
    topVC.present(ac, animated: true, completion: nil)
  }
}
