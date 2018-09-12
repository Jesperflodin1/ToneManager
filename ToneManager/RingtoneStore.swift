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
    let appDataDir = URL(fileURLWithPath: "/var/mobile/Library/ToneManager")
    let plistURL = URL(fileURLWithPath: "/var/mobile/Library/ToneManager/tones.plist")
    
    weak var tableView : UITableView?
    
    var zedge : Bool {
        get {
            return defaults.bool(forKey: "ZedgeRingtones")
        }
    }
    var audikoLite : Bool {
        get {
            return defaults.bool(forKey: "AudikoLite")
        }
    }
    var audikoPro : Bool {
        get {
            return defaults.bool(forKey: "AudikoPro")
        }
    }
    
    var autoInstall : Bool {
        get {
            return defaults.bool(forKey: "AutoInstall")
        }
    }
    
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
        
        loadFromPlist()
    }
    
    /// Loads ringtones from plist. Will also verify all loaded ringtones if shouldVerifyRingtones=true
    ///
    /// - Parameter shouldVerifyRingtones: will verify ringtones if true, is by default false
    func loadFromPlist(_ shouldVerifyRingtones : Bool = true) {
        DispatchQueue.global(qos: .background).async {

            var ringtonesArray : Array<Ringtone> = []
            
            do {
                let data = try Data(contentsOf: self.plistURL)
                let decoder = PropertyListDecoder()
                ringtonesArray = try decoder.decode(Array<Ringtone>.self, from: data)
                BFLog("Success reading plist: \(ringtonesArray)")
            } catch {
                Bugfender.error("Error when reading ringtones from plist: \(error)")
            }
            if shouldVerifyRingtones {
                ringtonesArray = self.verifyRingtones(inArray: ringtonesArray)
            }
            DispatchQueue.main.async {
                self.allRingtones = WriteLockableSynchronizedArray(with: ringtonesArray)
                
                self.createTestRingtones()
                
                self.tableView?.reloadData()
            }
        }
    }
    
    func writeToPlist() {
        guard let ringtones = allRingtones.array else {
            Bugfender.error("Failed to get ringtones array")
            return
        }
        let ringtonesArrayCopy : Array<Ringtone> = ringtones.map(){ $0.copy() as! Ringtone }
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        do {
            let data = try encoder.encode(ringtonesArrayCopy)
            try data.write(to: plistURL)
            BFLog("Done writing plist")
        } catch {
            Bugfender.error("Error when writing ringtones to plist: \(error)")
        }
    }
    
    /// Verifies if ringtones are valid. Calls isValid on every ringtone in array. Removes invalid ringtones.
    ///
    /// - Parameter ringtonesArray: Array with ringtones to verify
    /// - Returns: Array which only contains valid ringtones
    func verifyRingtones(inArray ringtonesArray : Array<Ringtone>) -> Array<Ringtone> {
        return ringtonesArray.filter { $0.isValid() }
    }
    
    func ringtoneAppsToScan() -> Array<String> {
        var apps : Array<String> = []
        
        if zedge {
            if let path = FBApplicationInfoHandler.path(forBundleIdentifier: "com.zedge.Zedge") {
                apps.append(path.appendingPathComponent("Documents").path)
            }
        }
        if audikoLite {
            if let path = FBApplicationInfoHandler.path(forBundleIdentifier: "com.908.AudikoFree") {
                apps.append(path.appendingPathComponent("Documents").path)
            }
        }
        if audikoPro {
            if let path = FBApplicationInfoHandler.path(forBundleIdentifier: "com.908.Audiko") {
                apps.append(path.appendingPathComponent("Documents").path)
            }
        }
        
        return apps
    }
    
    /// Rescans default and/or chosen apps for new ringtones and imports them. Uses RingtoneScanner class for this
    ///
    /// - Parameter completionHandler: completion block that should run when import is done, a Bool indicating if new ringtones
    /// was imported is passed to it.
    func updateRingtones(completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let scanner = RingtoneScanner(self)
            // TODO: Get extra apps to scan from preferences
            
            var apps = self.ringtoneAppsToScan()
            apps.append("/test")
            if apps.count > 0 {
                BFLog("Paths to scan: \(apps)")
                if let newArray = scanner.importRingtonesFrom(paths: apps) {
    
                    DispatchQueue.main.async {
                        self.allRingtones = WriteLockableSynchronizedArray(with: newArray)
                        completionHandler(true)
                    }
                } else {
                    BFLog("Scan did not find anything new")
                    DispatchQueue.main.async {
                        completionHandler(false)
                    }
                }
                
            } else {
                BFLog("0 paths to scan, skipping scan")
                DispatchQueue.main.async {
                    completionHandler(false)
                }
            }
        }
        
    }
    
}
