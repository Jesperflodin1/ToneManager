//
//  RingtoneStore.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

class RingtoneStore {
    
    var allRingtones = [Ringtone]()
    
    @discardableResult func createTestRingtone() -> Ringtone {
        let newTone = Ringtone(filePath: "/var/Containers/something/Documents/ringtone    pls--   åäö!.m4r", bundleID: "com.908.AudikoFree")
        
        allRingtones.append(newTone)
        return newTone
    }
    
    init() {
        createTestRingtone()
        createTestRingtone()
        createTestRingtone()
        createTestRingtone()
        createTestRingtone()
    }
    
}
