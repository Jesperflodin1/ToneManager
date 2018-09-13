//
//  Ringtone.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//
import Foundation
import BugfenderSDK

// MARK: - String Extension for removing extra whitespace
public extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
// MARK: - URL Extension for generating a ringtone name from its filename
public extension URL {
    func nameFromFilePath() -> String {
        let filename = self.deletingPathExtension().lastPathComponent
        
        let characterSet = CharacterSet(charactersIn: " ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-").inverted
        let components = filename.components(separatedBy: characterSet)
        let name = components.joined(separator: "")
        
        return name.condenseWhitespace()
    }
}

/// Model class for one ringtone. Stores metadata
public class Ringtone : NSObject, NSCopying, Codable {
    
    
    /// Name visible in the ringtone picker
    private(set) var name: String
    /// Identifier used by tonelibrary
    public var identifier: String?
    
    /// Length of ringtone
    public let totalTime: Int
    /// Bundle ID it was imported from
    public let bundleID: String
    /// Location for ringtone as URL
    public let fileURL: URL
    /// Always false
    public let protectedContent: Bool
    /// Always false
    public let purchased: Bool
    
    /// Appname (from bundle id) to show in the RingtoneTableView
    public let appName: String
    /// File size of ringtone
    public let size: Int
    
//    private let queue = DispatchQueue(label: "fi.flodin.tonemanager.RingtoneSerialQueue")
    
    /// Creates a copy of this ringtone object
    ///
    /// - Parameter zone: ?
    /// - Returns: New ringtone with same values as this ringtone
    public func copy(with zone: NSZone? = nil) -> Any {
        return Ringtone(name: self.name, identifier: self.identifier, totalTime: self.totalTime, bundleID: self.bundleID, fileURL: self.fileURL, protectedContent: self.protectedContent, purchased: self.purchased)
    }
    
    
    /// Init method
    ///
    /// - Parameters:
    ///   - name: Name to show in the ringtone picker
    ///   - identifier: tone identifier (assigned by TLToneManager in ToneLibrary)
    ///   - totalTime: Length of ringtone
    ///   - bundleID: bundle id this was imported from
    ///   - fileURL: Full path to ringtone
    ///   - protectedContent: Required by tonelibrary. Defaults to false
    ///   - purchased: Required by tonelibrary. Defaults to false
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

        self.name = name
        self.identifier = identifier
        
        var fileSize = 0
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attribute[FileAttributeKey.size] as? Int {
                fileSize = size
            }
        } catch {
            Bugfender.error("Could not get file size for path: \(fileURL) Error: \(error)")
        }
        self.size = fileSize

        super.init()
    }
    
    /// Convenience init method
    ///
    /// - Parameters:
    ///   - filePath: Full path to ringtone
    ///   - bundleID: bundleid this ringtone was imported from
    convenience init(filePath: String, bundleID: String) {
        let url = URL(fileURLWithPath: filePath)
        let generatedName = url.nameFromFilePath()
        
        self.init(name: generatedName, identifier:nil , totalTime: nil, bundleID: bundleID, fileURL: url)
    }
    
    /// Uses ToneLibrary to check if this ringtone is valid. It will be valid if it has an identifier that exists in
    /// this devices tonelibrary. Also checks if fileURL exists. If toneIdentifier is nil, ringtone is considered valid
    /// ( if file exists)
    ///
    /// - Returns: true if valid
    public func isValid() -> Bool {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: fileURL.path) {
            return false // file does not exist
        }
        
        guard let toneIdentifier = self.identifier else { return true }
        guard let toneManager = TLToneManagerHandler.sharedInstance() else { return false }
        
        return toneManager.tone(withIdentifierIsValid: toneIdentifier)
    }
    
    /// Returns data object with data from ringtone file
    ///
    /// - Returns: Data from ringtone file
    public func getData() -> Data? {
        do {
            let data = try Data(contentsOf: self.fileURL)
            return data
        } catch {
            Bugfender.error("Error when retrieving data for ringtone. Error: \(error)")
            return nil
        }
    }
    
    /// Returns description string for this ringtone
    public override var description: String {
        get {
            return "<Ringtone name:\(self.name), identifier: \(self.identifier ?? "nil"), URL: \(self.fileURL)>"
        }
    }

}
