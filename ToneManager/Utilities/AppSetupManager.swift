//
//  AppSetupManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-18.
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
    
    class func clearTempFolder() {
        let fileManager = FileManager.default
        let tempFolderURL = appDataDir.appendingPathComponent("tmp", isDirectory: true)
        let tempConvertingURL = tempFolderURL.appendingPathComponent("converting", isDirectory: true)
        let inboxPathURL = URL(fileURLWithPath: "/var/mobile/Library/Application Support/Containers/fi.flodin.ToneManager/Documents/Inbox/")
        let URLs = [tempFolderURL, tempConvertingURL, inboxPathURL]
        
        for url in URLs {
            do {
                let filePaths = try fileManager.contentsOfDirectory(atPath: url.path)
                for filePath in filePaths {
                    try fileManager.removeItem(atPath: filePath)
                }
            } catch {
                BFLog("Could not clear temp folder: %@ Error: \(error as NSError)", url.path)
            }
        }
    }
}
