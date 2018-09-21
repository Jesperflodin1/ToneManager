//
//  RingtoneAssigner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-20.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import Contacts
import BugfenderSDK
import PKHUD

class RingtoneAssigner: NSObject {
    
    let ringtone : Ringtone
    
    init?(ringtone : Ringtone) {
        guard ringtone.identifier != nil else { return nil }
        self.ringtone = ringtone
    }
    
    func assignDefaultRingtone() {
        TLToneManagerHandler.sharedInstance().setCurrentToneIdentifier(ringtone.identifier, forAlertType: 1)
    }
    
    func assignDefaultRingtone(forContact: CNContact) {
        if CNMutableContactHandler.init(contact: forContact).setCallAlert(self.ringtone.identifier) {
            HUD.flash(.label("Set ringtone to contact successfully"), delay: 1.0)
        } else {
            HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when setting ringtone to contact"), delay: 1.0)
            Bugfender.error("Got false from setCallAlert on contact")
        }
        
    }
    
    func assignDefaultTextTone() {
        TLToneManagerHandler.sharedInstance().setCurrentToneIdentifier(ringtone.identifier, forAlertType: 2)
    }
    
    func assignDefaultTextTone(forContact: CNContact) {
        if CNMutableContactHandler.init(contact: forContact).setTextAlert(self.ringtone.identifier) {
            HUD.flash(.label("Set text tone to contact successfully"), delay: 1.0)
        } else {
            HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when setting text tone to contact"), delay: 1.0)
            Bugfender.error("Got false from setTextAlert on contact")
        }
        
    }
    
    
    
}


