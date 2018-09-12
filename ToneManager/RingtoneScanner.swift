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
    /// path for app data
    private let appDataPath = "/var/mobile/Library/ToneManager"
    
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
    /// - Returns: sorted array of all imported ringtones including new and old. Nil if nothing was imported
    public func importRingtonesFrom(paths pathsArray : Array<String>) -> Array<Ringtone>? {
        
        BFLog("Starting scan for paths: \(pathsArray)")
        
        guard let tempArray = delegate.allRingtones.array else {
            Bugfender.error("Failed to get ringtones array")
            return nil
        }
        
        var ringtonesArrayCopy : Array<Ringtone> = tempArray.map(){ $0.copy() as! Ringtone }
        BFLog("Got copy of ringtone array: \(ringtonesArrayCopy)")
        
        var importedCount : Int = 0
        
        let fileManager = FileManager.default
        
        for currentPath in pathsArray {
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
                let pathExtension = URL(fileURLWithPath: file).pathExtension
                if pathExtension != "m4r" { continue }
                
                
            }
            
            
        }
        if importedCount > 0 {
            return tempArray
        } else {
            return nil
        }
    
    }
    
}
