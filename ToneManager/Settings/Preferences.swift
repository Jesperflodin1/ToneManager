//
//  Preferences.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-15.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

/// Preferences struct, uses Userdefaults
struct Preferences {
    
    /// Userdefaults object
    static let defaults = UserDefaults.standard
    
    enum keys : String {
        case autoInstall = "AutoInstall"
        case remoteLogging = "RemoteLogging"
        case audikoLite = "AudioLite"
        case audikoPro = "AudikoPro"
        case zedgeRingtones = "ZedgeRingtones"
        case extraApps = "ExtraApps"
        case version = "Version"
        case build = "Build"
        case firstRun = "FirstRun"
        case isUpdated = "IsUpdated"
    }
    
    static let defaultSettings : [String:Any] = [
        Preferences.keys.autoInstall.rawValue : true,
        Preferences.keys.remoteLogging.rawValue : true,
        Preferences.keys.audikoLite.rawValue : true,
        Preferences.keys.audikoPro.rawValue : true,
        Preferences.keys.zedgeRingtones.rawValue : true,
        Preferences.keys.extraApps.rawValue : [String](),
        Preferences.keys.version.rawValue : "0.5.0",
        Preferences.keys.build.rawValue : "1",
        Preferences.keys.firstRun.rawValue : true,
        Preferences.keys.isUpdated.rawValue : false
    ]
    
    static let defaultApps : [String:String] = [
        Preferences.keys.zedgeRingtones.rawValue : "com.zedge.Zedge",
        Preferences.keys.audikoLite.rawValue : "com.908.AudikoFree",
        Preferences.keys.audikoPro.rawValue : "com.908.Audiko"
    ]
    
    static let zedgeItunesId : NSNumber = 584485870
    static let audikoLiteItunesId : NSNumber = 878910012
    static let audikoProItunesId : NSNumber = 725401575
    
    static let defaultExcludedFileExtensions = ["zip", "txt", "jpg", "jpeg", "png", "gif", "deb", "xml"]
    static let fileBrowserDefaultPath = "/var/mobile"
}

//MARK: Simple setters and getters
extension Preferences {
    
    static var autoInstall : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.autoInstall.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.autoInstall.rawValue)
        }
    }
    
    static var remoteLogging : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.remoteLogging.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.remoteLogging.rawValue)
        }
    }
    
    static var audikoLite : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.audikoLite.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.audikoLite.rawValue)
        }
    }
    
    static var audikoPro : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.audikoPro.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.audikoPro.rawValue)
        }
    }
    
    static var zedgeRingtones : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.zedgeRingtones.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.zedgeRingtones.rawValue)
        }
    }
    
    static var extraApps : [String] {
        get {
            return Preferences.defaults.stringArray(forKey: Preferences.keys.extraApps.rawValue) ?? [String]()
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.extraApps.rawValue)
        }
    }
    
    static var version : String {
        get {
            return Preferences.defaults.string(forKey: Preferences.keys.version.rawValue)!
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.version.rawValue)
        }
    }
    
    static var build : Int {
        get {
            return Preferences.defaults.integer(forKey: Preferences.keys.build.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.build.rawValue)
        }
    }
    
    static var firstRun : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.firstRun.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.firstRun.rawValue)
        }
    }
    
    static var isUpdated : Bool {
        get {
            return Preferences.defaults.bool(forKey: Preferences.keys.isUpdated.rawValue)
        }
        set {
            Preferences.defaults.set(newValue, forKey: Preferences.keys.isUpdated.rawValue)
        }
    }
}

//MARK: Calculated getters
extension Preferences {
    
    /// Gets bundle ids of apps to scan depending on userdefaults values
    ///
    /// - Returns: Array with bundle ids
    static var ringtoneAppsToScan : Array<String> {
        var apps : Array<String> = []
        
        if Preferences.zedgeRingtones {
            apps.append(Preferences.defaultApps[Preferences.keys.zedgeRingtones.rawValue]!)
        }
        if Preferences.audikoLite {
            apps.append(Preferences.defaultApps[Preferences.keys.audikoLite.rawValue]!)
        }
        if Preferences.audikoPro {
            apps.append(Preferences.defaultApps[Preferences.keys.audikoPro.rawValue]!)
        }
        
        if extraApps.count > 0 {
            apps.append(contentsOf: extraApps)
        }
        
        return apps
    }
    
    static func extraAppIsEnabled(_ appIdentifier : String) -> Bool {
        if extraApps.contains(appIdentifier) {
            return true
        }
        return false
    }
    
    static func extraAppEnable(_ appIdentifier : String) {
        var apps = extraApps
        if !apps.contains(appIdentifier) {
            apps.append(appIdentifier)
            extraApps = apps
        }
    }
    
    static func extraAppDisable(_ appIdentifier : String) {
        var apps = extraApps
        if let index = apps.index(of: appIdentifier) {
            apps.remove(at: index)
            extraApps = apps
        }
    }
    
}

//MARK: Install status
extension Preferences {
    static var audikoLiteInstalled : Bool {
        return FBApplicationInfoHandler.installedStatus(forBundleId: Preferences.defaultApps[Preferences.keys.audikoLite.rawValue]!)
    }
    static var audikoProInstalled : Bool {
        return FBApplicationInfoHandler.installedStatus(forBundleId: Preferences.defaultApps[Preferences.keys.audikoPro.rawValue]!)
    }
    static var zedgeRingtonesInstalled : Bool {
        return FBApplicationInfoHandler.installedStatus(forBundleId: Preferences.defaultApps[Preferences.keys.zedgeRingtones.rawValue]!)
    }
}

//MARK: Methods
extension Preferences {
    
    /// Sets default user settings for UserDefaults
    static func registerDefaults() {
        Preferences.defaults.register(defaults: defaultSettings)
        if defaults.dictionaryRepresentation().count > 0 {
            BFLog("Current settings: %@", defaults.dictionaryRepresentation().description)
        }
    }
    
    static func reset() {
        for (key, value) in defaultSettings {
            Preferences.defaults.set(value, forKey: key)
        }
    }
    
    static func compareVersions() {
        let version : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        let build : Any! = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion")
        
        guard let currentVersion = version as? String else { return }
        guard let currentBuild = build as? String else { return }
        
        if currentVersion.isVersion(greaterThan: Preferences.version) {
            if !firstRun {
                Preferences.isUpdated = true
            } else {
                Preferences.isUpdated = false
            }
            Preferences.version = currentVersion
            guard let buildInt = Int(currentBuild) else { return }
            Preferences.build = buildInt
        }
    }
    
    static func firstRunDone() {
        Preferences.firstRun = false
    }
    
    static func updateDone() {
        Preferences.isUpdated = false
    }
}
