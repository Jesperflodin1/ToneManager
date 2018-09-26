//
//  Ringtone.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
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
import AVFoundation

/// Model class for one ringtone. Stores metadata
final class Ringtone : NSObject, Codable {
    
    /// Name visible in the ringtone picker
    private(set) var name: String
    
    func changeName(_ newName: String, ignoreInstalledStatus: Bool) {
        BFLog("Changing name to: %@ for ringtone: %@", self.name, self.description)
        if ignoreInstalledStatus {
            self.name = newName
            NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
            return
        }
        if self.installed {
            BFLog("ringtone is installed, uninstalling first")
            RingtoneManager.uninstallRingtone(ringtoneObject: self, useHUD: false) {
                self.name = newName
                NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
                RingtoneManager.installRingtone(ringtoneObject: self, useHUD: false, onSuccess: {
                    NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
                })
            }
        } else {
            self.name = newName
            NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
        }
        
    }
    
    /// Identifier used by tonelibrary
    var identifier: String?
    
    /// Length of ringtone as Int, calculated from ’Ringtone.rawDuration’
    var totalTime: Int {
        get {
            return NSNumber(value: round(self.rawDuration)).intValue
        }
    }
    
    var installed: Bool {
        get {
            guard identifier != nil else { return false }
            return true
        }
    }
    
    /// duration in seconds, as double
    let rawDuration : Double
    
    /// Bundle ID it was imported from
    let bundleID: String
    
    /// Location for ringtone as URL
    let fileURL: URL
    
    /// Always false
    let protectedContent: Bool
    
    /// Always false
    let purchased: Bool
    
    /// Appname (from bundle id) to show in the RingtoneTableView
    let appName: String
    
    /// File size of ringtone
    let size: Int
    
    
    //MARK: Initializers
    /// Init method
    ///
    /// - Parameters:
    ///   - name: Name to show in the ringtone picker
    ///   - identifier: tone identifier (assigned by TLToneManager in ToneLibrary)
    ///   - duration: Length of ringtone in seconds, as double
    ///   - bundleID: bundle id this was imported from
    ///   - fileURL: Full path to ringtone
    ///   - protectedContent: Required by tonelibrary. Defaults to false
    ///   - purchased: Required by tonelibrary. Defaults to false
    init(name: String, identifier: String?, duration: Double?, bundleID: String?, fileURL: URL, protectedContent: Bool? = nil, purchased: Bool? = nil) {
        self.fileURL = fileURL
        
        if let time = duration {
            self.rawDuration = NSNumber(value: time).doubleValue
        } else {
            do
            {
                let avAudioPlayer = try AVAudioPlayer(contentsOf: fileURL)
                let duration = avAudioPlayer.duration
                self.rawDuration = duration
            }
            catch{
                Bugfender.error("Error when retrieving duration of ringtone: \(error)")
                self.rawDuration = 0
            }
        }
        
        if let bundle = bundleID {
            self.bundleID = bundle
        } else {
            self.bundleID = "unknown.app"
        }
        
        if let protected = protectedContent {
            self.protectedContent = protected
        } else {
            self.protectedContent = false
        }
        
        if let purchasedTone = purchased {
            self.purchased = purchasedTone
        } else {
            self.purchased = false
        }
        
        if let app = FBApplicationInfoHandler.displayName(forBundleIdentifier: self.bundleID) {
            self.appName = app
        } else if self.bundleID == Bundle.main.bundleIdentifier {
            self.appName = "Manual import"
        } else {
            self.appName = self.bundleID
        }
        
        self.name = name
        self.identifier = identifier
        
        var fileSize = 0
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attribute[FileAttributeKey.size] as? Int {
                fileSize = size
            }
        } catch {
            Bugfender.error("Could not get file size for path: \(error)")
        }
        self.size = fileSize
        
        super.init()
    }
    
    /// Convenience init method
    ///
    /// - Parameters:
    ///   - filePath: Full path to ringtone
    ///   - bundleID: bundleid this ringtone was imported from
    ///   - appendRandomToName: true if a short random string should be appended to ringtone name
    convenience init(filePath: String, bundleID: String, appendRandomToName : Bool = false) {
        let url = URL(fileURLWithPath: filePath)
        var generatedName = url.nameFromFilePath()
        if appendRandomToName {
            generatedName.appendRandom()
        }
        
        self.init(name: generatedName, identifier:nil , duration: nil, bundleID: bundleID, fileURL: url)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        name = try values.decode(String.self, forKey: .name)
        identifier = try values.decodeIfPresent(String.self, forKey: .identifier)
        rawDuration = try values.decode(Double.self, forKey: .rawDuration)
        bundleID = try values.decode(String.self, forKey: .bundleID)
        fileURL = try values.decode(URL.self, forKey: .fileURL)
        protectedContent = try values.decode(Bool.self, forKey: .protectedContent)
        purchased = try values.decode(Bool.self, forKey: .purchased)
        appName = try values.decode(String.self, forKey: .appName)
        size = try values.decode(Int.self, forKey: .size)
    }
    
    //MARK: Codable
    
    enum CodingKeys: String, CodingKey {
        case name
        case identifier
        case rawDuration
        case bundleID
        case fileURL
        case protectedContent
        case purchased
        case appName
        case size
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(identifier, forKey: .identifier)
        try container.encode(rawDuration, forKey: .rawDuration)
        try container.encode(bundleID, forKey: .bundleID)
        try container.encode(fileURL, forKey: .fileURL)
        try container.encode(protectedContent, forKey: .protectedContent)
        try container.encode(purchased, forKey: .purchased)
        try container.encode(appName, forKey: .appName)
        try container.encode(size, forKey: .size)
    }
}


//MARK: NSCopying
extension Ringtone: NSCopying {
    
    /// Creates a copy of this ringtone object
    ///
    /// - Parameter zone: ?
    /// - Returns: New ringtone with same values as this ringtone
    func copy(with zone: NSZone? = nil) -> Any {
        return Ringtone(name: self.name, identifier: self.identifier, duration: self.rawDuration, bundleID: self.bundleID, fileURL: self.fileURL, protectedContent: self.protectedContent, purchased: self.purchased)
    }
    
}


//MARK: Calculated values
extension Ringtone {
    
    /// Uses ToneLibrary to check if this ringtone is valid. It will be valid if it has an identifier that exists in
    /// this devices tonelibrary. Also checks if fileURL exists. If toneIdentifier is nil, ringtone is considered valid
    /// ( if file exists)
    ///
    /// - Returns: true if valid
    func isValid() -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            Bugfender.warning("ringtone does not exist, path: \(fileURL.path)")
            return false // file does not exist
        }
        
        guard let toneIdentifier = self.identifier else { return true }
        guard let toneManager = TLToneManagerHandler.sharedInstance() else { return true }
        
        let result = toneManager.tone(withIdentifierIsValid: toneIdentifier)
        BFLog("Verifing ringtone: %@, result: %d", self, result)
        if !result {
            try? fileManager.removeItem(atPath: fileURL.path)
        }
        
        return result
    }
    
    func isDefaultRingtone() -> Bool {
        if !isValid() {
            return false
        }
        if TLToneManagerHandler.sharedInstance().currentToneIdentifier(forAlertType: 1) == self.identifier {
            BFLog("I am default ringtone, woohoo! %@",self.description)
            return true
        }
        return false
    }
    func isDefaultTextTone() -> Bool {
        if !isValid() {
            return false
        }
        if TLToneManagerHandler.sharedInstance().currentToneIdentifier(forAlertType: 2) == self.identifier {
            BFLog("I am default texttone, woohoo! %@",self.description)
            return true
        }
        return false
    }
    
    /// Returns description string for this ringtone
    override var description: String {
        get {
            return String(format: "<Ringtone name: %@, identifier: %@, Path: %@>", self.name, self.identifier ?? "nil", self.fileURL.path)
        }
    }
    
    func humanReadableSize() -> String {
        let byteCount = self.size
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(byteCount))
    }
}

//MARK: Actions
extension Ringtone {
    /// Returns data object with data from ringtone file
    ///
    /// - Returns: Data from ringtone file
    func getData() -> Data? {
        do {
            let data = try Data(contentsOf: self.fileURL)
            return data
        } catch {
            Bugfender.error("Error when retrieving data for ringtone. Error: \(error)")
            return nil
        }
    }
    
    /// Deletes the file this ringtone object is associated with
    func deleteFile() {
        do {
            try FileManager.default.removeItem(at: self.fileURL)
        } catch {
            Bugfender.error("Error when deleting ringtone file: \(error)")
        }
    }
}
