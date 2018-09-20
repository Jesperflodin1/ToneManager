//
//  RingtoneAssigner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-20.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import ContactsUI

class RingtoneAssigner: NSObject {
    
    let ringtone : Ringtone
    
    init(ringtone : Ringtone) {
        self.ringtone = ringtone
    }
    
    func assignDefaultRingtone() {
        
        
    }
    
    func assignDefaultTextTone() {
        
    }
    
    func openContactPicker() {
        
    }
    
    
}

extension RingtoneAssigner : CNContactPickerDelegate {

    
    
}
