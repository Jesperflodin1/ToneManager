//
//  RingtoneLibraryProxy.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

class ToneLibraryProxy {
    
    var knownRingtones : [String:String] = [:]
    
    init() {
        enumerateToneLibrary()
    }

    fileprivate func enumerateToneLibrary() {
        do {
            let fileManager = FileManager.default
            let importedTones = try fileManager.contentsOfDirectory(atPath: toneLibraryDir.path)
            let filteredTones = importedTones.filter { $0.hasPrefix("import_") }
            
            guard let toneManager = TLToneManagerHandler.sharedInstance() else { return }
            BFLog("Enumerating tonelibrary files: %@", filteredTones.description)
            for file in filteredTones {
                if let identifier = toneManager._toneIdentifierForFile(atPath: toneLibraryDir.appendingPathComponent(file, isDirectory: false).path), let name = toneManager.name(forToneIdentifier: identifier) {
                    knownRingtones.updateValue(identifier, forKey: name)
                }
            }
            
            BFLog("Successfully enumerated tonelibrary, got: %@", knownRingtones.description)
        } catch {
            Bugfender.error("Error when enumerating tonelibrary: \(error as NSError)")
        }
    }
    
    func identifierFromName(_ name : String) -> String? {
        return knownRingtones[name]
    }
    
    func setIdentifierIfToneIsInstalled(_ ringtone : Ringtone) -> Bool {
        BFLog("set identifier called for ringtone: %@", ringtone.description)
        if ringtone.identifier != nil { return true }
        
        guard let identifier = identifierFromName(ringtone.name), let filePath = TLToneManagerHandler.sharedInstance().filePath(forToneIdentifier: identifier) else { return false }
        
        // if duration or size is equal
        if URL(fileURLWithPath: filePath).rawAudioDurationOfFile() == ringtone.rawDuration || URL(fileURLWithPath: filePath).size() == ringtone.size {
            ringtone.identifier = identifier
            return true
        }
        
        return false
    }
    
}
