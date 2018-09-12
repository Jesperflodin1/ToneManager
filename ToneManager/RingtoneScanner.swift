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
class RingtoneScanner {
    /// <#Description#>
    private let appDataPath = "/var/mobile/Library/ToneManager"
    
    /// <#Description#>
    var delegate : RingtoneStore
    
    /// <#Description#>
    ///
    /// - Parameter delegate: <#delegate description#>
    init(_ delegate : RingtoneStore) {
        self.delegate = delegate
        BFLog("Scanner initializing")
    }
    
    // Files with same name from different apps will try to import, but tonelibrary wont import them
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - pathsArray: <#pathsArray description#>
    ///   - completionHandler: <#completionHandler description#>
    func importRingtonesFrom(paths pathsArray : Array<String>) -> Array<Ringtone>? {
        
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
                
            }
            
            
        }
        if importedCount > 0 {
            return tempArray
        } else {
            return nil
        }
    
    }
    
}
