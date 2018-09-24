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

public let plistURL = URL(fileURLWithPath: "/var/mobile/Library/ToneManager/tones.plist")

/// Model class for ringtones
final class RingtoneStore {
    
    /// Path to local plist for ringtone metadata
    
    
    var finishedLoading : Bool = false
    
    /// WriteLockableSynchronizedArray for all ringtones
    var allRingtones = WriteLockableSynchronizedArray<Ringtone>()
    
    var installedRingtones : Array<Ringtone> {
        get {
            return allRingtones.filter { $0.installed }
        }
    }
    
    var notInstalledRingtones : Array<Ringtone> {
        get {
            return allRingtones.filter { !$0.installed }
        }
    }
    
    /// Serial queue for reading/writing plist
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.SerialRingtoneStorePListReaderWriterQueue")
    
    public func createTestRingtones() {
        for i in 1...5 {
            let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone\(i)    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
            
            allRingtones.append(newTone)
        }
        self.finishedLoading = true
        NotificationCenter.default.post(name: .ringtoneStoreDidFinishLoading, object: nil)
    }
    
    static let sharedInstance = RingtoneStore()
    
    var backgroundTaskIdentifier : UIBackgroundTaskIdentifier!
    
    /// Init method. Checks folder existence and if necessary creates application data folder
    init() {
        BFLog("RingtoneStore init")
        NSLog("RingtoneStore init")
        
        backgroundTaskIdentifier = UIBackgroundTaskInvalid
        registerObservers()
        
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
}

//MARK: Plist reading and writing
extension RingtoneStore {
    
    /// Loads ringtones from plist. Will also verify all loaded ringtones if shouldVerifyRingtones=true (defaults to true). Dispatches work to serial queue.
    ///
    /// - Parameter shouldVerifyRingtones: will verify ringtones if true, is by default true
    public func loadFromPlist(_ shouldVerifyRingtones : Bool = true) {
        queue.sync {
            //TODO: Check if tones.plist exist. If it does and reading failes, try to rebuild database!
            
            BFLog("Trying to read plist")
            do {
                let data = try Data(contentsOf: plistURL)
                
                let decoder = PropertyListDecoder()
                let ringtonesArray = try decoder.decode(Array<Ringtone>.self, from: data)
                
                if shouldVerifyRingtones {
                    let newRingtonesArray = self.verifyRingtones(inArray: ringtonesArray)
                    
                    self.allRingtones = WriteLockableSynchronizedArray(with: newRingtonesArray)
                    
                    
                } else {
                    self.allRingtones = WriteLockableSynchronizedArray(with: ringtonesArray)
                }
                
                // Sort
                let sortedTones = self.allRingtones.sorted(by: { (initial, next) -> Bool in
                    return initial.name.lowercased().compare(next.name.lowercased()) == .orderedAscending
                })
                self.allRingtones = WriteLockableSynchronizedArray(with: sortedTones)
            } catch {
                #if targetEnvironment(simulator)
                self.createTestRingtones()
                #endif
                NSLog("Error when reading ringtones from plist: \(error)")
                Bugfender.error("Error when reading ringtones from plist: \(error)")
            }
            
            
            
            
            //            DispatchQueue.main.sync {
            
            
            //            }
            self.finishedLoading = true
            NotificationCenter.default.post(name: .ringtoneStoreDidFinishLoading, object: nil)
        }
        
        
    }
    
    /// Writes all currently known ringtones to local plist. Dispatches work to serial queue
    public func writeToPlist() {
        if !finishedLoading { return }
        
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
                try data.write(to: plistURL)
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
        NSLog("Verifying ringtones")
        return ringtonesArray.filter { $0.isValid() }
    }
}

//MARK: Ringtone install/uninstall methods
extension RingtoneStore {
    /// Uses ’RingtoneInstaller’ to install ringtone
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to install
    ///   - completionHandler: Completion block to execute when import is done. Ringtone object is passed as argument, identifier will be set if import was successful
    func installRingtone(_ ringtone : Ringtone, completionHandler: @escaping (Ringtone, Bool) -> Void) {
        let installer = RingtoneInstaller(self)
        BFLog("Calling ringtone install for ringtone")
        installer.installRingtone(ringtone, completionHandler: completionHandler)
        
    }
    
    func installAllRingtones(inArray ringtoneArray: [Ringtone]? = nil, completionHandler: @escaping (Int, Int) -> Void) {
        let tonesToInstall : [Ringtone]
        if let ringtones = ringtoneArray {
            tonesToInstall = ringtones
        } else {
            tonesToInstall = self.notInstalledRingtones
        }
        
        let installer = RingtoneInstaller(self)
        BFLog("install all ringtones, count = %d", tonesToInstall.count)
        
        installer.installRingtones(inArray: tonesToInstall, completionHandler: completionHandler)
    }
    
    /// Uses ’RingtoneInstaller’ to uninstall ringtone
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone object to uninstall
    ///   - completionHandler: Completion block to execute when uninstall is done. Ringtone object is passed as argument, identifier will be set if it was successful
    func uninstallRingtone(_ ringtone : Ringtone, completionHandler: @escaping (Bool) -> Void) {
        
        let installer = RingtoneInstaller(self)
        
        BFLog("calling uninstall for ringtone: %@", ringtone.name)
        
        installer.removeRingtone(ringtone, deleteFile: false, completionHandler: completionHandler)
        
    }
    
    func uninstallAllRingtones(completionHandler: @escaping (Int, Int) -> Void) {
        let tonesToUninstall = self.installedRingtones
        
        let installer = RingtoneInstaller(self)
        
        BFLog("Uninstall all ringtones, count = %d", tonesToUninstall.count)
        
        installer.removeRingtones(inArray: tonesToUninstall, deleteFiles: false, completionHandler: completionHandler)
    }
    
    /// Removes ringtone from database and filesystem. Also removes from tonelibrary if identifier is set
    ///
    /// - Parameters:
    ///   - ringtone: Ringtone to remove
    ///   - completion: Optional completion block to run when done. Runs in main queue
    func removeRingtone(_ ringtone : Ringtone, completion: @escaping (Bool) -> Void) {
        BFLog("Delete was called for ringtone: %@", ringtone)
        
        let installer = RingtoneInstaller(self)
        
        installer.removeRingtone(ringtone, deleteFile: true, shouldCallBackToStore: true, completionHandler: completion)
    }
    
    func removeAllRingtones(completionHandler: @escaping (Int, Int) -> Void) {
        guard let tonesToUninstall = self.allRingtones.array else { return }
        
        let installer = RingtoneInstaller(self)
        
        BFLog("Delete all ringtones, count = %d", tonesToUninstall.count)
        
        installer.removeRingtones(inArray: tonesToUninstall, deleteFiles: true, completionHandler: completionHandler)
    }
}

//MARK: Ringtone Scanning methods
extension RingtoneStore {
    /// Rescans default and/or chosen apps for new ringtones and imports them. Uses RingtoneScanner class for this. Also sorts the ringtone array by name, ascending
    ///
    /// - Parameter completionHandler: completion block that should run when import is done, a Bool indicating if new ringtones
    /// was imported is passed to it.
    func updateRingtones(completionHandler: @escaping (Bool, [Ringtone]?) -> Void) {
        BFLog("Update called, finishedloading=%d", self.finishedLoading)
        if !finishedLoading { return }
        
        queue.async {
            let scanner = RingtoneScanner()
            
            let apps = Preferences.ringtoneAppsToScan
            //            apps.append("/test")
            if apps.count > 0 {
                BFLog("Paths to scan: %@", apps)
                if let newArray = scanner.importRingtonesFrom(apps: apps) {
                    BFLog("Ringtone import success, got new ringtones")
                    
                    DispatchQueue.main.async {
                        self.allRingtones.append(newArray)
                        let sortedTones = self.allRingtones.sorted(by: { (initial, next) -> Bool in
                            return initial.name.lowercased().compare(next.name.lowercased()) == .orderedAscending
                        })
                        self.allRingtones = WriteLockableSynchronizedArray(with: sortedTones)
                        
                        completionHandler(true, newArray)
                    }
                } else {
                    BFLog("Scan did not find anything new")
                    DispatchQueue.main.async {
                        completionHandler(false, nil)
                    }
                }
                
            } else {
                BFLog("0 paths to scan, skipping scan")
                DispatchQueue.main.async {
                    completionHandler(false, nil)
                }
            }
            self.writeToPlist()
        }
    }
    
    func importFile(_ fileURL : URL, completionHandler: @escaping (Bool, NSError?, Ringtone?) -> Void) {
        queue.async {
            let fileImporter = RingtoneFileImporter()
            fileImporter.importFile(fileURL, completionHandler: { (success, ringtone) in
                if !success {
                    let error = fileImporter.importError ?? NSError(domain: ErrorDomain.ringtoneStore.rawValue, code: ErrorCode.unknownImportError.rawValue, userInfo: nil)
                    Bugfender.error("Got error when trying to import single file, errorcode=\(error as NSError)")
                    DispatchQueue.main.async {
                        completionHandler(false, error, nil)
                    }
                } else if let tone = ringtone {
                    DispatchQueue.main.async {
                        self.allRingtones.append(tone)
                        let sortedTones = self.allRingtones.sorted(by: { (initial, next) -> Bool in
                            return initial.name.lowercased().compare(next.name.lowercased()) == .orderedAscending
                        })
                        self.allRingtones = WriteLockableSynchronizedArray(with: sortedTones)
                        self.writeToPlist()
                        completionHandler(true, nil, tone)
                    }
                }
            })
        }
    }
}

//MARK: Notification observers
extension RingtoneStore {
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    // Called from notification observer when app will enter background or terminate. Writes ringtone plist to disk.
    @objc func didEnterBackground() {
        
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
            
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        })
        
        DispatchQueue.global(qos: .default).async {
            
            self.writeToPlist()
            UserDefaults.standard.synchronize()
            
            BFLog("Saved plist when app entered background")
            
            UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid
        }
    }
}
