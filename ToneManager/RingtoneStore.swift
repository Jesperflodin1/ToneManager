//
//  RingtoneStore.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

/// Model class for ringtones
class RingtoneStore {
    
    let defaults = UserDefaults.standard
    
    /// WriteLockableSynchronizedArray for all ringtones
    var allRingtones = WriteLockableSynchronizedArray<Ringtone>()

    func createTestRingtones() {
        for i in 1...5 {
            let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone\(i)    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
            
            allRingtones.append(newTone)
        }
        
    }
    
    /// Init method. Checks folder existence and if necessary creates application data folder
    init() {
        BFLog("RingtoneStore init")
        
        let fileManager = FileManager.default
        let appDataDir = URL(fileURLWithPath: "/var/mobile/Library/ToneManager")
        if !fileManager.fileExists(atPath: appDataDir.path) {
            BFLog("No app data directory found, creating")
            do {
                try fileManager.createDirectory(atPath: appDataDir.path, withIntermediateDirectories: true, attributes: nil)
                BFLog("Successfully created application data folder")
            } catch {
                Bugfender.error("Couldn't create document directory. Am i really running in jailbroken mode?")
            }
        } else {
            BFLog("App data directory exists")
        }
        
        createTestRingtones()
    }
    
    /// Rescans default and/or chosen apps for new ringtones and imports them. Uses RingtoneScanner class for this
    ///
    /// - Parameter completionHandler: completion block that should run when import is done, a Bool indicating if new ringtones
    /// was imported is passed to it.
    func updateRingtones(completionHandler: @escaping (Bool) -> Void) {
        let scanner = RingtoneScanner(self)
        // TODO: Get apps to scan from preferences
        
    }
    
}
