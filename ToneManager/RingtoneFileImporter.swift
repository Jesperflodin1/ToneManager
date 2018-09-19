//
//  RingtoneFileImporter.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import FileBrowser

final class RingtoneFileImporter: RingtoneScanner {
    
    /// Serial queue for file importer tasks
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.FileImporterSerialQueue")
    
    let knownExtensions : [String] = ["m4r"]
    
    func importFile(_ file : FBFile, completionHandler: (Bool) -> Void) {
        
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
