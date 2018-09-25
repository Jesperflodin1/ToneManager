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
        BFLog("App version: %@ Build: %@",Preferences.version,String(Preferences.build))
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
    
    class func report_memory() {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                          task_flavor_t(MACH_TASK_BASIC_INFO),
                          $0,
                          &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            BFLog("Memory in use (in bytes): \(info.resident_size)")
        }
        else {
            BFLog("Error with task_info(): " +
                (String(cString: mach_error_string(kerr), encoding: String.Encoding.ascii) ?? "unknown error"))
        }
    }
}
