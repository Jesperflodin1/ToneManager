//
//  AppSetupManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-18.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

class AppSetupManager {
    
    class func doSetupIfNeeded() {
        Preferences.compareVersions()
        BFLog("App version: \(Preferences.version) Build: \(Preferences.build)")
        if Preferences.firstRun {
            BFLog("First run setup")
            registerAppWithSystem()
            Preferences.firstRunDone()
        } else if Preferences.isUpdated {
            BFLog("App has been updated")
            Preferences.updateDone()
        }
    }
    
    class func registerAppWithSystem() {
        LSApplicationWorkspaceHandler.registerApplicationDictionary()
    }
}
