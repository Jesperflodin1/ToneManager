//
//  RingtoneManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import PKHUD
import PopupDialog
import BugfenderSDK
import FileBrowser

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
        
        RingtoneStore.sharedInstance.updateRingtones { (needsUpdate: Bool, newRingtones: [Ringtone]?)  in
            
            BFLog("updateringtones callback")
            if (needsUpdate) {
                BFLog("updateringtones callback, got true for needsupdate")
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Updated available ringtones"), delay: 0.5)
                
                guard let importedTones = newRingtones else { return }
                if !Preferences.autoInstall {
                    completionHandler?()
                    return
                } else {
                    installAllRingtones(inArray: importedTones, withAlert: false, onSuccess: completionHandler)
                }
            }
        }
    }
}

//MARK: Install methods
extension RingtoneManager {
    
    class func importRingtoneFile(_ file : FBFile, onSuccess: @escaping (() -> Void)) {
        importRingtoneURL(file.filePath, onSuccess: onSuccess)
    }
    
    fileprivate class func handleError(_ errorType: NSError) {
        switch errorType.code {
        case ErrorCode.invalidRingtoneFile.rawValue:
            HUD.flash(.labeledError(title: "Error", subtitle: "File is not a valid ringtone"), delay: 1.0)
            return
        case ErrorCode.fileAlreadyImported.rawValue:
            HUD.flash(.labeledError(title: "Error", subtitle: "File is already imported"), delay: 1.0)
            return
        case ErrorCode.copyFailure.rawValue:
            HUD.flash(.labeledError(title: "Error", subtitle: "Failed to copy file"), delay: 1.0)
            return
        default:
            HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when importing ringtone"), delay: 1.0)
            return
        }
    }
    
    class func importRingtoneURL(_ fileURL : URL, onSuccess: @escaping (() -> Void)) {
        RingtoneStore.sharedInstance.importFile(fileURL, completionHandler: { (success, error, ringtone) in
            if !success {
                guard let errorType = error else { return }
                Bugfender.error("Import failure")
                return handleError(errorType)
            } else { // import success
                BFLog("Import success")
                HUD.flash(.labeledSuccess(title: "Success", subtitle: "Imported 1 Ringtone"), delay: 0.7)
                
                if !Preferences.autoInstall {
                    onSuccess()
                    return
                } else {
                    installRingtone(ringtoneObject: ringtone, onSuccess: onSuccess)
                }
            }
        })
    }
    
    class func handleAlreadyImportedError(forFile fileURL : URL, onSuccess: @escaping () -> Void) {
        
    }
    
    class func installRingtone(inCell: RingtoneTableCell? = nil, ringtoneObject: Ringtone? = nil, onSuccess: (() -> Void)? = nil) {

        let ringtone : Ringtone
        let cell : RingtoneTableCell?
        if let celltemp = inCell, let ringtonetemp = celltemp.ringtoneItem {
            ringtone = ringtonetemp
            cell = celltemp
        } else if let ringtonetemp = ringtoneObject {
            ringtone = ringtonetemp
            cell = nil
        } else {
            HUD.flash(.labeledError(title: "Error", subtitle: "Invalid arguments when installing ringtone"), delay: 1.0)
            return
        }

        RingtoneStore.sharedInstance.installRingtone(ringtone, completionHandler: { (installedRingtone, success) in
            if (success) {
                
                BFLog("Got success in callback from ringtone install")
                if let cellNotNil = cell {
                    cellNotNil.updateInstallStatus()
                }
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed ringtone"), delay: 0.7)
                onSuccess?()
            } else {
                //TODO: retry once with appendrandom to name
                BFLog("Got failure in callback from ringtone install")
                HUD.flash(.labeledError(title: "Error", subtitle: "Error when installing ringtone"), delay: 1.0)
            }
        })
    }
    
    
    class func installAllRingtones(inArray ringtoneArray : [Ringtone]? = nil, withAlert : Bool = true, onSuccess: (() -> Void)? = nil) {
        let toneCount : Int
        if ringtoneArray == nil {
            toneCount = RingtoneStore.sharedInstance.notInstalledRingtones.count
        
            if toneCount == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.label("All available ringtones are already installed"), delay: 1.0)
                return
            }
        } else {
            toneCount = ringtoneArray!.count
        }
        
        let completionHandler = { (installedTones : Int, failedTones : Int) in
            
            if installedTones > 0, failedTones == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones"), delay: 1.0)
            } else if installedTones > 0, failedTones > 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones, however \(failedTones) failed to install"), delay: 1.0)
            } else if installedTones == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were installed because of an unknown error"), delay: 1.0)
                return
            } else {
                HUD.allowsInteraction = true
                HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
                return
            }
            
            onSuccess?()
        }
        
        if withAlert {
            let title = "Install \(toneCount) ringtones?"
            let message = "Are you sure you want to install \(toneCount) ringtones?"
            let popup = PopupDialog(title: title, message: message, image: ColorPalette.alertBackground)
            let buttonTwo = CancelButton(title: "Cancel", action: nil)
            let buttonOne = DefaultButton(title: "Install") {
                HUD.show(.labeledProgress(title: "Installing", subtitle: "Installing ringtones"))
                
                BFLog("Calling install for multiple ringtones")
                
                RingtoneStore.sharedInstance.installAllRingtones(inArray: ringtoneArray, completionHandler: completionHandler)
            }

            popup.addButtons([buttonOne, buttonTwo])
            
            guard let topVC = UIApplication.topViewController() else {
                Bugfender.error("Could not get top view controller when trying to display alert")
                return
            }
            topVC.present(popup, animated: true, completion: nil)
        } else {
            HUD.show(.labeledProgress(title: "Installing", subtitle: "Installing ringtones"))
            
            BFLog("Calling install for multiple ringtones")
            
            RingtoneStore.sharedInstance.installAllRingtones(inArray: ringtoneArray, completionHandler: completionHandler)
        }
    }
}

//MARK: Uninstall methods
extension RingtoneManager {
    
    class func uninstallRingtone(inCell: RingtoneTableCell? = nil, ringtoneObject: Ringtone? = nil, onSuccess: (() -> Void)? = nil) {
        let ringtone : Ringtone
        let cell : RingtoneTableCell?
        if let celltemp = inCell, let ringtonetemp = celltemp.ringtoneItem {
            ringtone = ringtonetemp
            cell = celltemp
        } else if let ringtonetemp = ringtoneObject {
            ringtone = ringtonetemp
            cell = nil
        } else {
            HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when uninstalling ringtone"), delay: 0.7)
            return
        }
            
        RingtoneStore.sharedInstance.uninstallRingtone(ringtone, completionHandler: { (success) in
            if success {
                if let cellNotNil = cell {
                    cellNotNil.updateInstallStatus()
                }
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled ringtone"), delay: 0.7)
                onSuccess?()
            } else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when uninstalling ringtone"), delay: 1.0)
            }
        })
    }
    
    class func uninstallAll(withAlert : Bool = true, onSuccess: (() -> Void)? = nil) {
        let toneCount = RingtoneStore.sharedInstance.installedRingtones.count
        if toneCount == 0 {
            HUD.allowsInteraction = true
            HUD.flash(.label("No ringtones are installed"), delay: 1.0)
            return
        }
        
        let completionHandler = { (uninstalledTones : Int, failedTones : Int) in
            
            if uninstalledTones > 0, failedTones == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled \(uninstalledTones) ringtones"), delay: 1.0)
            } else if uninstalledTones > 0, failedTones > 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled \(uninstalledTones) ringtones, however \(failedTones) failed to install"), delay: 1.0)
            } else if uninstalledTones == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were uninstalled because of an unknown error"), delay: 1.0)
            } else {
                HUD.allowsInteraction = true
                HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
            }
            
            onSuccess?()
        }
        
        if withAlert {
            let title = "Uninstall \(toneCount) ringtones?"
            let message = "Are you sure you want to uninstall \(toneCount) ringtones?"
            let popup = PopupDialog(title: title, message: message, image: ColorPalette.alertBackground)
            let buttonTwo = CancelButton(title: "Cancel", action: nil)
            let buttonOne = DestructiveButton(title: "Uninstall") {
                HUD.show(.labeledProgress(title: "Uninstalling", subtitle: "Uninstalling ringtones"))
                
                BFLog("Calling uninstall for multiple ringtones")
                
                RingtoneStore.sharedInstance.uninstallAllRingtones(completionHandler: completionHandler)
            }
            
            popup.addButtons([buttonOne, buttonTwo])
            
            guard let topVC = UIApplication.topViewController() else {
                Bugfender.error("Could not get top view controller when trying to display alert")
                return
            }
            topVC.present(popup, animated: true, completion: nil)
        } else {
            HUD.show(.labeledProgress(title: "Uninstalling", subtitle: "Uninstalling all ringtones"))
            
            BFLog("Calling uninstall for all ringtones")
            
            RingtoneStore.sharedInstance.uninstallAllRingtones(completionHandler: completionHandler)
        }
    }
}

//MARK: Delete methods
extension RingtoneManager {
    
    class func deleteRingtone(inCell: RingtoneTableCell? = nil, ringtoneObject: Ringtone? = nil, onSuccess: (() -> Void)? = nil) {
        let ringtone : Ringtone
        if let celltemp = inCell, let ringtonetemp = celltemp.ringtoneItem {
            ringtone = ringtonetemp
        } else if let ringtonetemp = ringtoneObject {
            ringtone = ringtonetemp
        } else {
            HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when deleting ringtone"), delay: 0.7)
            return
        }
        
        RingtoneStore.sharedInstance.removeRingtone(ringtone, completion: { (success) in
            if success {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted ringtone"), delay: 0.7)
            } else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when deleting ringtone"), delay: 1.0)
            }
            
            onSuccess?()
        })
    }
    
    class func deleteAllRingtones(withAlert : Bool = true, onSuccess: (() -> Void)? = nil) {
        let toneCount = RingtoneStore.sharedInstance.allRingtones.count
        if toneCount == 0 {
            HUD.allowsInteraction = true
            HUD.flash(.label("No ringtones are imported"), delay: 1.0)
            return
        }
        
        let completionHandler = { (uninstalledTones : Int, failedTones : Int) in
            
            if uninstalledTones > 0, failedTones == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted \(uninstalledTones) ringtones"), delay: 1.0)
            } else if uninstalledTones > 0, failedTones > 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted \(uninstalledTones) ringtones, however \(failedTones) failed to delete"), delay: 1.0)
            } else if uninstalledTones == 0 {
                HUD.allowsInteraction = true
                HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were deleted because of an unknown error"), delay: 1.0)
            } else {
                HUD.allowsInteraction = true
                HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
            }
            
            onSuccess?()
        }
        
        if withAlert {
            let title = "Delete \(toneCount) ringtones?"
            let message = "Are you sure you want to delete \(toneCount) ringtones?"
            let popup = PopupDialog(title: title, message: message, image: ColorPalette.alertBackground)
            let buttonTwo = CancelButton(title: "Cancel", action: nil)
            let buttonOne = DestructiveButton(title: "Delete all") {
                HUD.show(.labeledProgress(title: "Deleting", subtitle: "Deleting ringtones"))
                
                BFLog("Calling delete for all ringtones")
                
                RingtoneStore.sharedInstance.removeAllRingtones(completionHandler: completionHandler)
            }
            
            popup.addButtons([buttonOne, buttonTwo])
            
            guard let topVC = UIApplication.topViewController() else {
                Bugfender.error("Could not get top view controller when trying to display alert")
                return
            }
            topVC.present(popup, animated: true, completion: nil)
        } else {
            HUD.show(.labeledProgress(title: "Deleting", subtitle: "Deleting all ringtones"))
            
            BFLog("Calling delete for all ringtones")
            
            RingtoneStore.sharedInstance.removeAllRingtones(completionHandler: completionHandler)
        }
    }
}
