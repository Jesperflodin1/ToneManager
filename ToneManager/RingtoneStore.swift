//
//  RingtoneStore.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

/// Global variable for application data folder
public let appDataDir = URL(fileURLWithPath: "/var/mobile/Library/ToneManager")

/// Model class for ringtones
public class RingtoneStore {
    
    /// Userdefaults.standard
    public let defaults = UserDefaults.standard
    
    /// Path to local plist for ringtone metadata
    public let plistURL = URL(fileURLWithPath: "/var/mobile/Library/ToneManager/tones.plist")
    
    /// Reference to tableView for RingtoneTableViewController
    public weak var tableView : UITableView?
    
    /// Gets "ZedgeRingtones" value from userdefaults
    public var zedge : Bool {
        get {
            return defaults.bool(forKey: "ZedgeRingtones")
        }
    }
    /// Gets "AudikoLite" value from userdefaults
    public var audikoLite : Bool {
        get {
            return defaults.bool(forKey: "AudikoLite")
        }
    }
    /// Gets "AudikoPro" value from userdefaults
    public var audikoPro : Bool {
        get {
            return defaults.bool(forKey: "AudikoPro")
        }
    }
    
    /// Gets "AutoInstall" value from userdefaults
    public var autoInstall : Bool {
        get {
            return defaults.bool(forKey: "AutoInstall")
        }
    }
    
    /// WriteLockableSynchronizedArray for all ringtones
    public var allRingtones = WriteLockableSynchronizedArray<Ringtone>()
    
    /// Serial queue for reading/writing plist
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.SerialRingtoneStorePListReaderWriterQueue")

    public func createTestRingtones() {
        for i in 1...5 {
            let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone\(i)    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
            
            allRingtones.append(newTone)
        }
        
    }
    
    /// Init method. Checks folder existence and if necessary creates application data folder
    init() {
        BFLog("RingtoneStore init")
        
        createAppDir()
        
        loadFromPlist()
    }
    
    /// Creates application data directory if possible and needed
    private func createAppDir() {
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
    }
    
    /// Loads ringtones from plist. Will also verify all loaded ringtones if shouldVerifyRingtones=true (defaults to true). Dispatches work to serial queue.
    ///
    /// - Parameter shouldVerifyRingtones: will verify ringtones if true, is by default true
    public func loadFromPlist(_ shouldVerifyRingtones : Bool = true) {
        queue.sync {

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
                
                self.writeToPlist()
                
                self.tableView?.reloadData()
            }
        }
    }
    
    /// Writes all currently known ringtones to local plist. Dispatches work to serial queue
    public func writeToPlist() {
        queue.async {
            guard let ringtones = self.allRingtones.array else {
                Bugfender.error("Failed to get ringtones array")
                return
            }
            self.createAppDir()
            let ringtonesArrayCopy : Array<Ringtone> = ringtones.map(){ $0.copy() as! Ringtone }
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .binary
            do {
                let data = try encoder.encode(ringtonesArrayCopy)
                try data.write(to: self.plistURL)
                BFLog("Done writing plist")
            } catch {
                Bugfender.error("Error when writing ringtones to plist: \(error)")
            }
        }
    }
    
    /// Verifies if ringtones are valid. Calls isValid on every ringtone in array. Removes invalid ringtones.
    ///
    /// - Parameter ringtonesArray: Array with ringtones to verify
    /// - Returns: Array which only contains valid ringtones
    public func verifyRingtones(inArray ringtonesArray : Array<Ringtone>) -> Array<Ringtone> {
        return ringtonesArray.filter { $0.isValid() }
    }
    
    /// Gets bundle ids of apps to scan depending on userdefaults values
    ///
    /// - Returns: Array with bundle ids
    public func ringtoneAppsToScan() -> Array<String> {
        var apps : Array<String> = []
        
        if zedge {
            apps.append("com.zedge.Zedge")
        }
        if audikoLite {
            apps.append("com.908.AudikoFree")
        }
        if audikoPro {
            apps.append("com.908.Audiko")
        }
        
        return apps
    }
    
    /// Uses ’RingtoneInstaller’ to install ringtone
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to install
    ///   - completionHandler: Completion block to execute when import is done. Ringtone object is passed as argument, identifier will be set if import was successful
    public func installRingtone(_ ringtone : Ringtone, completionHandler: @escaping (Ringtone) -> Void) {
        let installer = RingtoneInstaller()
        BFLog("Calling ringtone install for ringtone: \(ringtone)")
        installer.installRingtone(ringtone, completionHandler: completionHandler)
    }
    
    /// Uses ’RingtoneInstaller’ to uninstall ringtone
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to uninstall
    ///   - completionHandler: Completion block to execute when uninstall is done. Ringtone object is passed as argument, identifier will be set if it was successful
    public func uninstallRingtone(_ ringtone : Ringtone, completionHandler: @escaping (Ringtone) -> Void) {
        let installer = RingtoneInstaller()
        BFLog("calling uninstall for ringtone: \(ringtone)")
        
        guard let identifier = ringtone.identifier else {
            return
        }
        
        if installer.removeRingtoneWithIdentifier(identifier) {
            BFLog("uninstall success!")
            DispatchQueue.main.async {
                completionHandler(ringtone)
            }
        }
    }
    
    /// Removes ringtone from database and filesystem. Also removes from tonelibrary if identifier is set
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone to remove
    ///   - completion: Optional completion block to run when done. Runs in main queue
    public func removeRingtone(_ ringtone : Ringtone, completion: ((Ringtone) -> Void)? = nil) {
        BFLog("Delete was called for ringtone: \(ringtone)")
        if let identifier = ringtone.identifier {
            BFLog("Ringtone has identifier, trying to remove from tonelibrary")
            let installer = RingtoneInstaller()
            if !installer.removeRingtoneWithIdentifier(identifier) {
                Bugfender.warning("Failed to remove ringtone from tonelibrary: \(ringtone)")
                return
            }
            BFLog("Success removing identifier from tonelibrary")
        }
        ringtone.deleteFile()
        
        
        DispatchQueue.main.async {
            self.allRingtones.remove(where: { $0 == ringtone })
            self.writeToPlist()
            completion?(ringtone)
        }
        
    }
    
    /// Rescans default and/or chosen apps for new ringtones and imports them. Uses RingtoneScanner class for this. Also sorts the ringtone array by name, ascending
    ///
    /// - Parameter completionHandler: completion block that should run when import is done, a Bool indicating if new ringtones
    /// was imported is passed to it.
    public func updateRingtones(completionHandler: @escaping (Bool) -> Void) {
        DispatchQueue.global(qos: .background).async {
            let scanner = RingtoneScanner(self)
            // TODO: Get extra apps to scan from preferences
            
            let apps = self.ringtoneAppsToScan()
//            apps.append("/test")
            if apps.count > 0 {
                BFLog("Paths to scan: \(apps)")
                if let newArray = scanner.importRingtonesFrom(apps: apps) {
                    BFLog("Ringtone import success, got new ringtones: \(newArray)")
                    
                    DispatchQueue.main.async {
                        self.allRingtones.append(newArray)
                        self.allRingtones = WriteLockableSynchronizedArray(with: self.allRingtones.sorted(by: { (initial, next) -> Bool in
                            return initial.name.compare(next.name) == .orderedAscending
                        }))
                        self.writeToPlist()
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
