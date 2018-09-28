//
//  RingtoneScanner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-09.
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

/// Class that handles scanning and importing of ringtones
class RingtoneScanner {
    
    init() {
        BFLog("Scanner initializing")
    }
}

//MARK: Scanning and importing methods
extension RingtoneScanner {
    fileprivate func scan(_ currentApp: String, _ currentPath: URL) -> [Ringtone] {
        // we have files, check if we need to import (copy to app data folder and plist)
        // check based on filename (or name?) and maybe file size?
        var newRingtones = [Ringtone]()
        var filesArray : Array<String>
        do {
            filesArray = try FileManager.default.contentsOfDirectory(atPath: currentPath.path)
            BFLog("Found %d files: %@",filesArray.count ,filesArray.description)
        } catch {
            Bugfender.error("Error: Could not enumerate path: \(error as NSError)")
            return newRingtones // go to next iteration/folder
        }
        guard filesArray.count > 0 else {
            Bugfender.warning("No files found for path: \(currentPath.path)")
            return newRingtones // go to next iteration/folder
        }
        let enumerator : FileManager.DirectoryEnumerator?
        if !Preferences.scanRecursively { //only scan documents
            enumerator = FileManager.default.enumerator(at: currentPath.appendingPathComponent("Documents"), includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
        } else {
            enumerator = FileManager.default.enumerator(at: currentPath, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles])
        }
        
        while let fileUrl = enumerator?.nextObject() as? URL {
            
            let resourceValues = try? fileUrl.resourceValues(forKeys: [.isRegularFileKey])
            guard let regularFile = resourceValues?.isRegularFile else {
                Bugfender.error("Failed to get resource value regularfile for file: \(fileUrl.path)")
                continue
            }
//            guard let parentDirectoryURL = resourceValues?.parentDirectory else {
//                Bugfender.error("Failed to get parent url for file: \(fileUrl.path)")
//                continue
//            }
            if !regularFile {
                Bugfender.warning("File is not a regular file: \(fileUrl.path)")
                continue
            }
            
            let pathExtension = fileUrl.pathExtension
            if pathExtension != "m4r" { continue } // Skip non-m4r files
            
            var appendRandomToRingtoneName : Bool = false
            
            // Skip ringtones with same filename from same app
            if (RingtoneStore.sharedInstance.allRingtones.contains(where: { ($0.fileURL.lastPathComponent ==  fileUrl.lastPathComponent) && ($0.bundleID == currentApp) } )) {
                BFLog("File already exists: %@ for app: %@", fileUrl.path, currentApp)
                continue
            }
            
            // if filename already exists, but different app, prepare to set a different ringtone name
            if (RingtoneStore.sharedInstance.allRingtones.contains(where: { $0.fileURL.lastPathComponent ==  fileUrl.lastPathComponent } )) {
                BFLog("File already exists but different app, importing anyway: %@", fileUrl.path)
                appendRandomToRingtoneName = true
            }

            let ringtoneSourcePath = fileUrl.path
            
            guard let path = copyRingtoneToApp(ringtoneSourcePath, forBundleID: currentApp) else {
                Bugfender.error("Error when getting new filepath for ringtone, sourcepath = \(ringtoneSourcePath)")
                continue
            }
            
            let newRingtone = Ringtone(filePath: path, bundleID: currentApp, appendRandomToName: appendRandomToRingtoneName)
            
            newRingtones.append(newRingtone)
            
        }
        return newRingtones
    }
    
    /// Searches paths in pathsArray for ringtones that haven't yet been added to the database and adds them.
    /// Will copy the ringtones to the application data folder
    ///
    /// - Parameter pathsArray: Array of paths to search
    /// - Returns: sorted array of all new imported ringtones. Nil if nothing was imported
    func importRingtonesFrom(apps appsArray : Array<String>) -> Array<Ringtone>? {
        
        BFLog("Starting scan for apps: %@", appsArray)

        var newRingtones : Array<Ringtone> = []
        
        for currentApp in appsArray {
            guard let currentPath = FBApplicationInfoHandler.path(forBundleIdentifier: currentApp) else { continue }
            
//            let testPath1 = FBApplicationInfoHandler.sandboxURL(forBundleIdentifier: currentApp)
//            if let sandboxURL = testPath1 {
//                BFLog("sandBoxURL = %@", sandboxURL.path)
//            }
            
            
//            let docPath = currentPath.appendingPathComponent("Documents")
            
            BFLog("Scanning path: %@", currentPath.path)
            
//            newRingtones.append(contentsOf: scan(currentApp, docPath))
            newRingtones.append(contentsOf: scan(currentApp, currentPath))
            
        }
        if newRingtones.count > 0 {
            return newRingtones
        } else {
            return nil
        }
    }
    
    
}

//MARK: File importer
extension RingtoneScanner {
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
            if fileManager.fileExists(atPath: toFilePath.path) {
                try fileManager.removeItem(atPath: toFilePath.path)
                BFLog("Removed existing file at path: %@", toFilePath.path)
            }
            try fileManager.copyItem(atPath: path, toPath: toFilePath.path)
            BFLog("Copied file to path: %@", toFilePath.path)
            return toFilePath.path
        } catch {
            Bugfender.error("Error when copying file: \(error as NSError)")
        }
        return nil
    }
}
