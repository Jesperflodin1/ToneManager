//
//  Ringtone.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//
import Foundation

// MARK: - String Extension for removing extra whitespace
extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
// MARK: - URL Extension for generating a ringtone name from its filename
extension URL {
    func nameFromFilePath() -> String {
        let filename = self.deletingPathExtension().lastPathComponent
        
        let characterSet = CharacterSet(charactersIn: " ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-").inverted
        let components = filename.components(separatedBy: characterSet)
        let name = components.joined(separator: "")
        
        return name.condenseWhitespace()
    }
}

/// Model class for one ringtone. Stores metadata
class Ringtone : NSObject, NSCopying, Codable {
    
    
    /// Name visible in the ringtone picker
    private(set) var name: String
    /// Identifier used by tonelibrary
    private(set) var identifier: String?
    
    /// Length of ringtone
    let totalTime: Int
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
    
//    private let queue = DispatchQueue(label: "fi.flodin.tonemanager.RingtoneSerialQueue")
    
    func copy(with zone: NSZone? = nil) -> Any {
        return Ringtone(name: self.name, identifier: self.identifier, totalTime: self.totalTime, bundleID: self.bundleID, fileURL: self.fileURL, protectedContent: self.protectedContent, purchased: self.purchased)
    }
    
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - name: <#name description#>
    ///   - identifier: <#identifier description#>
    ///   - totalTime: <#totalTime description#>
    ///   - bundleID: <#bundleID description#>
    ///   - fileURL: <#fileURL description#>
    ///   - protectedContent: <#protectedContent description#>
    ///   - purchased: <#purchased description#>
    init(name: String, identifier: String?, totalTime: Int?, bundleID: String?, fileURL: URL, protectedContent: Bool? = nil, purchased: Bool? = nil) {
        
        self.fileURL = fileURL
        
        if let time = totalTime {
            self.totalTime = time
        } else {
            //TODO: calculate total time
            self.totalTime = 0
        }
        
        if let bundle = bundleID {
            self.bundleID = bundle
        } else {
            self.bundleID = "fi.flodin.tonemanager"
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
        } else {
            self.appName = self.bundleID
        }
        
        self.size = 0 // TODO: File size

        self.name = name
        self.identifier = identifier
        super.init()
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - filePath: <#filePath description#>
    ///   - bundleID: <#bundleID description#>
    convenience init(filePath: String, bundleID: String) {
        let url = URL(fileURLWithPath: filePath)
        let generatedName = url.nameFromFilePath()
        
        self.init(name: generatedName, identifier:nil , totalTime: nil, bundleID: bundleID, fileURL: url)
    }
    
    /// Uses ToneLibrary to check if this ringtone is valid. It will be valid if it has an identifier that exists in
    /// this devices tonelibrary. Also checks if fileURL exists. If toneIdentifier is nil, ringtone is considered valid ( if file exists)
    ///
    /// - Returns: true if valid
    func isValid() -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            return false // file does not exist
        }
        
        guard let toneIdentifier = self.identifier else { return true }
        guard let toneManager = TLToneManagerHandler.sharedInstance() else { return false }
        
        return toneManager.tone(withIdentifierIsValid: toneIdentifier)
    }

}
