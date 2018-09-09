//
//  RingtoneScanner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-09.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

class RingtoneScanner {
    private let appDataPath = "/var/mobile/Library/ToneManager"
    
    var delegate : RingtoneStore
    
    init(_ delegate : RingtoneStore) {
        self.delegate = delegate
        BFLog("Scanner initializing")
    }
    
    // Files with same name from different apps will try to import, but tonelibrary wont import them
    func importRingtonesFrom(paths pathsArray : Array<String>, completionHandler: @escaping (Bool) -> Void ) -> Void {
        
        DispatchQueue.global(qos: .background).async {
            BFLog("Starting scan for paths: \(pathsArray)")
            
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
                
                
                DispatchQueue.main.async {
                    completionHandler(true)
                }
            }
        }
    }
    
}
