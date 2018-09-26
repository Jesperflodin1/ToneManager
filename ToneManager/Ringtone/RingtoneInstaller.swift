//
//  RingtoneInstaller.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-12.
//
//
//  MIT License
//
//  Copyright (c) 2018 Jesper Flodin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation
import BugfenderSDK

/// Class that handles tonelibrary import and deletion of ringtones
final class RingtoneInstaller {
    
    /// Serial queue where import calls are placed
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.SerialRingtoneInstallerQueue")
    
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
                    RingtoneStore.sharedInstance.allRingtones.remove(where: { $0 == ringtone })
                }
                if shouldCallBackToStore {
                    RingtoneStore.sharedInstance.writeToPlist()
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
            RingtoneStore.sharedInstance.writeToPlist()
            completionHandler(uninstalledTones, failedTones)
        }
        
    }
}

//MARK: Install methods
extension RingtoneInstaller {
    
    fileprivate func handleInstall(status success: Bool,
                                   toneIdentifier: String?,
                                   ringtone: Ringtone,
                                   toneLibraryData: (metaData: [String:Any], toneData: Data),
                                   shouldCallBackToStore: Bool,
                                   retryOnFailure: Bool = false,
                                   completionHandler: @escaping (Ringtone, Bool) -> Void) {
        
        BFLog("handleinstall success=%d identifier=%@",success,toneIdentifier ?? "nil")
        if let identifierSuccess = toneIdentifier {
            BFLog("Import success, got identifier: %@", identifierSuccess)
            DispatchQueue.main.async { // to make sure tableview is not reloading
                ringtone.identifier = identifierSuccess
                if shouldCallBackToStore {
                    RingtoneStore.sharedInstance.writeToPlist()
                }
                
                completionHandler(ringtone, success)
            }
            
        } else if handleInstallError(ringtone) {
            //not success, check if name already installed and equals this tone
            Bugfender.warning("Ringtone install failed for ringtone: \(ringtone.description) Will search tonelibrary for matching name...")
            DispatchQueue.main.async { // to make sure tableview is not reloading
                if shouldCallBackToStore {
                    RingtoneStore.sharedInstance.writeToPlist()
                }
                
                completionHandler(ringtone, true)
            }
        } else {
            // Failed
            Bugfender.error("Ringtone install failed (retryonfailure=\(retryOnFailure), could not find installed ringtone with matching name and size/duration for tone: \(ringtone.description)")
            if retryOnFailure {
                
                var newName = ringtone.name
                newName.appendRandom()
                if RingtoneStore.sharedInstance.containsRingtoneWith(name: newName) { newName.appendRandom() }
                
                BFLog("Retrying ringtone install, oldname=%@, newname=%@",ringtone.name,newName)
                var newMetaData = toneLibraryData
                newMetaData.metaData.updateValue(newName, forKey: "Name")
                
                self.installRingtone(ringtone, toneLibraryData: newMetaData, retryOnFailure: false, completionHandler: { (tone, installStatus) in
                    DispatchQueue.main.async {
                        if installStatus {
                            ringtone.changeName(newName, ignoreInstalledStatus: true)
                        }
                        if shouldCallBackToStore {
                            RingtoneStore.sharedInstance.writeToPlist()
                        }
                        completionHandler(tone, installStatus)
                    }
                })
                
            } else {
                DispatchQueue.main.async { // to make sure tableview is not reloading
                    if shouldCallBackToStore {
                        RingtoneStore.sharedInstance.writeToPlist()
                    }
                    
                    completionHandler(ringtone, success)
                }
            }
        }
    }
    
    fileprivate func handleInstallError(_ ringtone : Ringtone) -> Bool {
        // does tone with this name already exist in tonelibrary?
        let library = ToneLibraryProxy()
        if library.setIdentifierIfToneIsInstalled(ringtone) {
            BFLog("Successfully set identifier for ringtone: %@", ringtone.description)
            return true
        }
        Bugfender.error("Current ringtone could not be installed and does not seem to already be installed, retry with different name")
        
        
        return false
    }
    
    fileprivate func prepareToneLibraryData(forRingtone ringtone: Ringtone) -> (metaData: [String:Any], toneData: Data)? {
        if ringtone.identifier != nil {
            BFLog("Ringtone is already installed, tone: %@", ringtone.fileURL.path)
            return nil
        }
        var toneLibraryMetaData = [String:Any]()
        toneLibraryMetaData["Name"] = ringtone.name
        toneLibraryMetaData["Total Time"] = NSNumber(value: ringtone.rawDuration*1000).intValue
        toneLibraryMetaData["Purchased"] = ringtone.purchased
        toneLibraryMetaData["Protected Content"] = ringtone.protectedContent
        
        guard let toneData = ringtone.getData() else {
            Bugfender.error("Could not get data for ringtone with path \(ringtone.fileURL.path)")
            return nil
        }
        
        return (toneLibraryMetaData, toneData)
    }
    
    /// Installs ringtone in tonelibrary
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to install
    ///   - completionHandler: Gets executed after import, ringtone object is passed to it. identifier is set if import was successful
    func installRingtone(_ ringtone : Ringtone,
                         toneLibraryData: (metaData: [String:Any], toneData: Data)? = nil,
                         shouldCallBackToStore: Bool = true,
                         retryOnFailure: Bool = false,
                         completionHandler: @escaping (Ringtone, Bool) -> Void)  {
        queue.async {
            if !TLToneManagerHandler.sharedInstance().canImport() {
                Bugfender.error("TLToneManager does not respond to required selectors, unknown error")
                DispatchQueue.main.async {
                    completionHandler(ringtone, false)
                }
                return
            }
            BFLog("Install called for ringtone: %@",ringtone.description)
            let toneLibraryTuple: (metaData: [String:Any], toneData: Data)
            if let metaData = toneLibraryData {
                toneLibraryTuple = metaData
            } else {
                guard let toneLibraryInfo = self.prepareToneLibraryData(forRingtone: ringtone) else { return }
                toneLibraryTuple = toneLibraryInfo
            }
            
            BFLog("Calling importTone with data: %@ metadata: %@", toneLibraryTuple.toneData.description, toneLibraryTuple.metaData)
            TLToneManagerHandler.sharedInstance().importTone(toneLibraryTuple.toneData, metadata: toneLibraryTuple.metaData) { (success : Bool, toneIdentifier : String?) in
                
                BFLog("Ringtone install completionblock, success: %d toneidentifier: %@", success, toneIdentifier ?? "nil")
                
                self.handleInstall(status: success,
                                   toneIdentifier: toneIdentifier,
                                   ringtone: ringtone,
                                   toneLibraryData: toneLibraryTuple,
                                   shouldCallBackToStore: shouldCallBackToStore,
                                   retryOnFailure: retryOnFailure,
                                   completionHandler: completionHandler)
                
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
            RingtoneStore.sharedInstance.writeToPlist()
            completionHandler(installedTones, failedTones)
        }
    }
}
