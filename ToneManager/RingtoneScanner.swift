//
//  RingtoneScanner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-09.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

class RingtoneScanner {
    private let appDataPath = "/var/mobile/Library/ToneManager"
    
    var delegate : RingtoneStore
    
    init(_ delegate : RingtoneStore) {
        self.delegate = delegate
        BFLog("Scanner initializing")
    }
    
    
    
}
