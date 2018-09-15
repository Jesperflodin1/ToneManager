//
//  Preferences.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-15.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

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
    }
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
}

//MARK: Calculated getters
extension Preferences {
    
    /// Gets bundle ids of apps to scan depending on userdefaults values
    ///
    /// - Returns: Array with bundle ids
    static var ringtoneAppsToScan : Array<String> {
        get {
            var apps : Array<String> = []
            
            if Preferences.zedgeRingtones {
                apps.append("com.zedge.Zedge")
            }
            if Preferences.audikoLite {
                apps.append("com.908.AudikoFree")
            }
            if Preferences.audikoPro {
                apps.append("com.908.Audiko")
            }
            
            return apps
        }
    }
    
}
