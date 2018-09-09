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
    
    var allRingtones = SynchronizedArray<Ringtone>()
    
    @discardableResult func createTestRingtone() -> Ringtone {
        let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
        
        allRingtones.append(newTone)
        return newTone
    }
    
    init() {
        BFLog("RingtoneStore init")
        createTestRingtone()
        createTestRingtone()
        createTestRingtone()
        createTestRingtone()
        createTestRingtone()
    }
    
//    func removeRingtone(_ ringtone: Ringtone, completion: ((Ringtone) -> Void)? = nil ) {
//        allRingtones.remove(where: {
//            $0 == ringtone
//        }, completion: completion)
//    }
    
    func updateRingtones(completionHandler: (Bool) -> Void) {
        
    }
    
}
