//
//  RingtoneStore.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

class RingtoneStore {
    
    var allRingtones = WriteLockableSynchronizedArray<Ringtone>()
    
    func createTestRingtones() {
        for i in 1...5 {
            let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone\(i)    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
            
            allRingtones.append(newTone)
        }
        
    }
    
    init() {
        BFLog("RingtoneStore init")
        createTestRingtones()
    }
    
//    func removeRingtone(_ ringtone: Ringtone, completion: ((Ringtone) -> Void)? = nil ) {
//        allRingtones.remove(where: {
//            $0 == ringtone
//        }, completion: completion)
//    }
    
    func updateRingtones(completionHandler: @escaping (Bool) -> Void) {
        let scanner = RingtoneScanner(self)
        // TODO: Get apps to scan from preferences
        
    }
    
}
