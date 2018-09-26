//
//  RingtoneLibraryProxy.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-25.
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
