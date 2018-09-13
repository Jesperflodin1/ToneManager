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
public class RingtoneInstaller {
    
    /// Serial queue where import calls are placed
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.SerialRingtoneInstallerQueue")
    
    /// Installs ringtone in tonelibrary
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to install
    ///   - completionHandler: Gets executed after import, ringtone object is passed to it. identifier is set if import was successful
    public func installRingtone(_ ringtone : Ringtone, completionHandler: @escaping (Ringtone) -> Void )  {
        queue.async {
            if !TLToneManagerHandler.sharedInstance().canImport() {
                Bugfender.error("TLToneManager does not respond to required selectors, unknown error")
                return
            }
            if ringtone.identifier == nil {
                BFLog("Ringtone is already imported, tone: \(ringtone)")
                return
            }
            var toneLibraryMetaData = [String:Any]()
            toneLibraryMetaData["Name"] = ringtone.name
            toneLibraryMetaData["Total Time"] = ringtone.totalTime
            toneLibraryMetaData["Purchased"] = ringtone.purchased
            toneLibraryMetaData["Protected Content"] = ringtone.protectedContent
            
            guard let toneData = ringtone.getData() else {
                Bugfender.error("Could not get data for ringtone with path (\(ringtone.fileURL.path))")
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
                completionHandler(ringtone)
            }
        }
    }
    
    /// Removes ringtone from tonelibrary
    ///
    /// - Parameter identifier: identifier to remove
    /// - Returns: returns true if successful
    public func removeRingtoneWithIdentifier(_ identifier : String) -> Bool {
        if !TLToneManagerHandler.sharedInstance().canImport() {
            Bugfender.error("TLToneManager does not respond to required selectors, unknown error")
            return false
        }
        
        TLToneManagerHandler.sharedInstance().removeImportedTone(withIdentifier: identifier)
        
        return true
    }
    
}
