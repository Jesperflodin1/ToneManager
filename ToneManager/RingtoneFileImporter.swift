//
//  RingtoneFileImporter.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import FileBrowser
import BugfenderSDK

final class RingtoneFileImporter: RingtoneScanner {
    
    /// Serial queue for file importer tasks
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.FileImporterSerialQueue")
    
    let knownExtensions : [String] = ["m4r"]
    
    func importFile(_ file : FBFile) -> Ringtone? {
        guard let fileExt = file.fileExtension else { return nil }
        if fileExt != "m4r" {
            //TODO: Try to convert
            return nil
        }
        
        let fileURL = file.filePath
        
        return importm4r(fileURL)
    }
    
    fileprivate func importm4r(_ fileURL : URL) -> Ringtone? {
        guard let currentApp = Bundle.main.bundleIdentifier else { return nil }
        
        var appendRandomToRingtoneName : Bool = false
        
        // Skip ringtones with same filename from same app
        if (RingtoneStore.sharedInstance.allRingtones.contains(where: { ($0.fileURL.lastPathComponent ==  fileURL.lastPathComponent) && ($0.bundleID == currentApp) } )) {
            BFLog("File already exists: \(fileURL.path) for app: \(currentApp)")
            return nil
        }
        
        // if filename already exists, but different app, prepare to set a different ringtone name
        if (RingtoneStore.sharedInstance.allRingtones.contains(where: { $0.fileURL.lastPathComponent ==  fileURL.lastPathComponent } )) {
            BFLog("File already exists but different app, importing anyway: \(fileURL.path)")
            appendRandomToRingtoneName = true
        }
        
        guard let path = copyRingtoneToApp(fileURL.path, forBundleID: currentApp) else {
            Bugfender.error("Error when getting new filepath for ringtone")
            return nil
        }
        
        let newRingtone = Ringtone(filePath: path, bundleID: currentApp, appendRandomToName: appendRandomToRingtoneName)
        return newRingtone
    }
    
    func importFile(atPath path : String) {
        
    }
    
    func isFileNameValid(_ name : String) {
        
    }
    
    func isFileValidRingtone(_ file : FBFile) -> Bool {
        if file.isDirectory { return false }
        guard let attributes = file.fileAttributes else { return false }
        if attributes.fileSize() < 1 { return false }
        
        guard let fileExt = file.fileExtension else { return false }
        if !knownExtensions.contains(fileExt) {
            return false
        }
        
        return true
    }
    
}
