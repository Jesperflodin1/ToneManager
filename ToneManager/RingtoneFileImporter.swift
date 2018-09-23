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
import AVFoundation

final class RingtoneFileImporter: RingtoneScanner {
    
    /// Serial queue for file importer tasks
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.FileImporterQueue")
    
    let knownExtensions : [String] = ["m4r"]
    
    func importFile(_ file : URL, completionHandler: @escaping (Bool, Ringtone?) -> ()) {
        queue.async {
            BFLog("Trying to import file: \(file)")
            if !self.knownExtensions.contains(file.pathExtension) {
                BFLog("File is not m4r, got extension: \(file.pathExtension)")
                //TODO: Try to convert
                completionHandler(false, nil)
            }
            
            if let tone = self.importm4r(file) {
                completionHandler(true, tone)
            } else {
                completionHandler(false, nil)
            }
        }
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
    
    func isFileValidRingtone(_ file : FBFile) -> Bool {
        BFLog("is file valid called")
        if file.isDirectory { return false }
        
        return isURLValidRingtone(file.filePath)
    }
    
    func isURLValidRingtone(_ fileURL : URL) -> Bool {
        BFLog("is fileurl valid called, got extension: \(fileURL.pathExtension)")
        
        if !knownExtensions.contains(fileURL.pathExtension) {
            return false
        }
        
        do
        {
            let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attribute[FileAttributeKey.size] as? Int {
                if size < 1 { return false }
            }
            
            let avAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            let duration = avAudioPlayer.duration
            if NSNumber(value: round(duration)).intValue > 40 { return false }
        }
        catch{
            Bugfender.error("Error when retrieving duration or size of file: \(fileURL), error: \(error)")
            return false
        }
        
        return true
    }
    
}
