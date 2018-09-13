//
//  RingtoneScanner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-09.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

/// Class that handles scanning and importing of ringtones
public class RingtoneScanner {
    
    /// Reference to RingtoneStore
    public var delegate : RingtoneStore
    
    /// Init method. Sets current ringtonestore as delegate
    ///
    /// - Parameter delegate: Current RingtoneStore
    init(_ delegate : RingtoneStore) {
        self.delegate = delegate
        BFLog("Scanner initializing")
    }
    
    /// Searches paths in pathsArray for ringtones that haven't yet been added to the database and adds them.
    /// Will copy the ringtones to the application data folder
    ///
    /// - Parameter pathsArray: Array of paths to search
    /// - Returns: sorted array of all new imported ringtones. Nil if nothing was imported
    public func importRingtonesFrom(apps appsArray : Array<String>) -> Array<Ringtone>? {
        
        BFLog("Starting scan for apps: \(appsArray)")
        
//        guard let tempArray = delegate.allRingtones.array else {
//            Bugfender.error("Failed to get ringtones array")
//            return nil
//        }
        
        var newRingtones : Array<Ringtone> = []
        
//        var ringtonesArrayCopy : Array<Ringtone> = tempArray.map(){ $0.copy() as! Ringtone }
//        BFLog("Got copy of ringtone array: \(ringtonesArrayCopy)")
        
        let fileManager = FileManager.default
        
        for currentApp in appsArray {
            guard let currentPath = FBApplicationInfoHandler.displayName(forBundleIdentifier: currentApp) else { continue }
            
            BFLog("Scanning path: \(currentPath)")
            
            var filesArray : Array<String>
            do {
                filesArray = try fileManager.contentsOfDirectory(atPath: currentPath)
                BFLog("Found files: \(filesArray)")
            } catch {
                Bugfender.error("Error: Could not enumerate path: \(currentPath) Error: \(error)")
                continue // go to next iteration/folder
            }
            guard filesArray.count > 0 else {
                Bugfender.warning("No files found for path: \(currentPath)")
                continue // go to next iteration/folder
            }
            
            // we have files, check if we need to import (copy to app data folder and plist)
            // check based on filename (or name?) and maybe file size?
            
            for file in filesArray {
                let fileUrl = URL(fileURLWithPath: file)
                let pathExtension = fileUrl.pathExtension
                if pathExtension != "m4r" { continue } // Skip non-m4r files
                
                // skip files with filename that already exists
                if (delegate.allRingtones.contains(where: { $0.fileURL.lastPathComponent ==  fileUrl.lastPathComponent } )) {
                    BFLog("File already exists: \(fileUrl)")
                    continue
                }
                
//                var fileSize = 0
//                do {
//                    let attribute = try FileManager.default.attributesOfItem(atPath: fileUrl.path)
//                    if let size = attribute[FileAttributeKey.size] as? Int { fileSize = size }
//                } catch {
//                    Bugfender.error("Could not get file size for path: \(fileUrl) Error: \(error)")
//                    continue
//                }
                
                // skip files with filesize that already exists
//                if (delegate.allRingtones.contains(where: { $0.fileURL ==  fileUrl } )) { continue }
                let ringtoneSourcePath = URL(fileURLWithPath: currentPath).appendingPathComponent(file, isDirectory: false)
                
                guard let path = copyRingtoneToApp(ringtoneSourcePath.path, forBundleID: currentApp) else {
                    Bugfender.error("Error when getting new filepath for ringtone")
                    continue
                }
                
                let newRingtone = Ringtone(filePath: path, bundleID: currentApp)
                
                newRingtones.append(newRingtone)
                
            }
            
            
        }
        if newRingtones.count > 0 {
            return newRingtones
        } else {
            return nil
        }
    
    }
    

    /// Copies file to subfolder "bundleid" in application data folder
    ///
    /// - Parameters:
    ///   - path: path to file to copy
    ///   - forBundleID: bundleid to use as subfolder
    /// - Returns: path file was copied to
    func copyRingtoneToApp(_ path : String, forBundleID : String) -> String? {
        let fileManager = FileManager.default
        
        let fileName = URL(fileURLWithPath: path).lastPathComponent
        
        let appDataSubfolder = appDataDir.appendingPathComponent(forBundleID, isDirectory: true)
        let toFilePath = appDataSubfolder.appendingPathComponent(fileName, isDirectory: false)
        
        do {
            try fileManager.createDirectory(at: appDataSubfolder, withIntermediateDirectories: true)
            try fileManager.copyItem(atPath: path, toPath: toFilePath.path)
            BFLog("Copied file to path: \(toFilePath.path)")
            return toFilePath.path
        } catch {
            Bugfender.error("Error when copying file: \(error)")
        }
        return nil
    }
    
}