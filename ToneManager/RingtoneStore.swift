//
//  RingtoneStore.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

/// <#Description#>
class RingtoneStore {
    
    /// <#Description#>
    var allRingtones = WriteLockableSynchronizedArray<Ringtone>()
    
    /// <#Description#>
    func createTestRingtones() {
        for i in 1...5 {
            let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone\(i)    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
            
            allRingtones.append(newTone)
        }
        
    }
    
    /// <#Description#>
    init() {
        BFLog("RingtoneStore init")
        createTestRingtones()
    }
    
    /// <#Description#>
    ///
    /// - Parameter completionHandler: <#completionHandler description#>
    func updateRingtones(completionHandler: @escaping (Bool) -> Void) {
        let scanner = RingtoneScanner(self)
        // TODO: Get apps to scan from preferences
        
    }
    
}
