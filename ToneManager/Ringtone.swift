//
//  Ringtone.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//
import Foundation

// MARK: - <#Description#>
extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
// MARK: - <#Description#>
extension URL {
    func nameFromFilePath() -> String {
        let filename = self.deletingPathExtension().lastPathComponent
        
        let characterSet = CharacterSet(charactersIn: " ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-").inverted
        let components = filename.components(separatedBy: characterSet)
        let name = components.joined(separator: "")
        
        return name.condenseWhitespace()
    }
}

/// <#Description#>
class Ringtone : NSObject {
    /// <#Description#>
    private(set) var name: String
    /// <#Description#>
    private(set) var identifier: String?
    
    /// <#Description#>
    let totalTime: Int
    /// <#Description#>
    let bundleID: String
    /// <#Description#>
    let fileURL: URL
    /// <#Description#>
    let protectedContent: Bool
    /// <#Description#>
    let purchased: Bool
    
    /// <#Description#>
    let appName: String
    /// <#Description#>
    let size: Int
    
    /// <#Description#>
    var installed : Bool {
        get { // If identifier is set, tone is considered installed.
            if self.identifier != nil {
                return true
            } else { return false }
        }
    }
    
//    private let queue = DispatchQueue(label: "fi.flodin.tonemanager.RingtoneSerialQueue")
    
    
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
    
    /// <#Description#>
    ///
    /// - Returns: <#return value description#>
    func isValid() -> Bool {
        guard let toneIdentifier = self.identifier else { return false }
        guard let toneManager = TLToneManagerHandler.sharedInstance() else { return false }
        
        return toneManager.tone(withIdentifierIsValid: toneIdentifier)
    }

}
