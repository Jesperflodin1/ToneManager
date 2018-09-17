//
//  RingtoneInstaller.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-12.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

/// Class that handles tonelibrary import and deletion of ringtones
final class RingtoneInstaller {
    
    /// Serial queue where import calls are placed
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.SerialRingtoneInstallerQueue", attributes: .concurrent)
    
    var ringtoneStore : RingtoneStore
    
    init(_ ringtoneStore: RingtoneStore) {
        self.ringtoneStore = ringtoneStore
    }
}

//MARK: Uninstall methods
extension RingtoneInstaller {
    /// Removes ringtone from tonelibrary
    ///
    /// - Parameter identifier: identifier to remove
    /// - Returns: returns true if successful
    func removeRingtone(_ ringtone : Ringtone, deleteFile : Bool = true, shouldCallBackToStore: Bool = true, completionHandler: @escaping (Bool) -> Void) {
        queue.async {
            if !TLToneManagerHandler.sharedInstance().canImport() {
                Bugfender.error("TLToneManager does not respond to required selectors, unknown error")
                DispatchQueue.main.async {
                    completionHandler(false)
                }
                return
            }
            if let identifier = ringtone.identifier {
                TLToneManagerHandler.sharedInstance().removeImportedTone(withIdentifier: identifier)
                ringtone.identifier = nil
            }
            
            if deleteFile {
                BFLog("Deleting ringtone file")
                ringtone.deleteFile()
            }
            
            DispatchQueue.main.async {
                
                if deleteFile {
                    self.ringtoneStore.allRingtones.remove(where: { $0 == ringtone })
                }
                if shouldCallBackToStore {
                    self.ringtoneStore.writeToPlist()
                }
                completionHandler(true)
            }
        }
    }
    
    func removeRingtones(inArray ringtonesArray: Array<Ringtone>, deleteFiles: Bool = false, completionHandler: @escaping (Int, Int) -> Void) {
        let group = DispatchGroup()
        
        BFLog("Starting uninstall for an array of ringtones with deletefiles = \(deleteFiles)")
        
        var uninstalledTones : Int = 0
        var failedTones : Int = 0
        
        for currentTone in ringtonesArray {
            
            group.enter()
            removeRingtone(currentTone, deleteFile: deleteFiles, shouldCallBackToStore: false, completionHandler: { (success) in
                if success {
                    uninstalledTones += 1
                } else {
                    failedTones += 1
                }
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            self.ringtoneStore.writeToPlist()
            completionHandler(uninstalledTones, failedTones)
        }
        
    }
}

//MARK: Install methods
extension RingtoneInstaller {
    
    /// Installs ringtone in tonelibrary
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to install
    ///   - completionHandler: Gets executed after import, ringtone object is passed to it. identifier is set if import was successful
    func installRingtone(_ ringtone : Ringtone, shouldCallBackToStore: Bool = true, completionHandler: @escaping (Ringtone, Bool) -> Void)  {
        queue.async {
            if !TLToneManagerHandler.sharedInstance().canImport() {
                Bugfender.error("TLToneManager does not respond to required selectors, unknown error")
                DispatchQueue.main.async {
                    completionHandler(ringtone, false)
                }
                return
            }
            if ringtone.identifier != nil {
                BFLog("Ringtone is already installed, tone: \(ringtone)")
                DispatchQueue.main.async {
                    completionHandler(ringtone, false)
                }
                return
            }
            var toneLibraryMetaData = [String:Any]()
            toneLibraryMetaData["Name"] = ringtone.name
            toneLibraryMetaData["Total Time"] = NSNumber(value: ringtone.rawDuration*1000).intValue
            toneLibraryMetaData["Purchased"] = ringtone.purchased
            toneLibraryMetaData["Protected Content"] = ringtone.protectedContent
            
            guard let toneData = ringtone.getData() else {
                Bugfender.error("Could not get data for ringtone with path (\(ringtone.fileURL.path))")
                DispatchQueue.main.async {
                    completionHandler(ringtone, false)
                }
                return
            }
            
            TLToneManagerHandler.sharedInstance().importTone(toneData, metadata: toneLibraryMetaData) { (success : Bool, toneIdentifier : String?) in
                if success && (toneIdentifier != nil) {
                    BFLog("Import success, got identifier: \(toneIdentifier ?? "nil")")
                    DispatchQueue.main.sync { // to make sure tableview is not reloading
                        ringtone.identifier = toneIdentifier
                    }
                    
                } else {
                    Bugfender.error("Ringtone install failed, got success=\(success) and identifier=\(toneIdentifier ?? "nil")")
                }
                DispatchQueue.main.async {
                    if shouldCallBackToStore {
                        self.ringtoneStore.writeToPlist()
                    }
                    
                    completionHandler(ringtone, success)
                }
            }
        }
    }
    
    func installRingtones(inArray ringtonesArray: Array<Ringtone>, completionHandler: @escaping (Int, Int) -> Void) {
        let group = DispatchGroup()
        
        BFLog("Starting install for an array of ringtones")
        
        var installedTones : Int = 0
        var failedTones : Int = 0
        
        for currentTone in ringtonesArray {
            
            group.enter()
            installRingtone(currentTone, shouldCallBackToStore: false) { (ringtone, success) in
                if success {
                    installedTones += 1
                } else {
                    failedTones += 1
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.ringtoneStore.writeToPlist()
            completionHandler(installedTones, failedTones)
        }
    }
}
