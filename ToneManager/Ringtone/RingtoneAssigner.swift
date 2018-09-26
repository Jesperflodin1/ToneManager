//
//  RingtoneAssigner.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-20.
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
import Contacts
import BugfenderSDK
import PKHUD
//TODO: Install ringtone first if not installed!!
class RingtoneAssigner: NSObject {
    
    let ringtone : Ringtone
    
    init(ringtone : Ringtone) {
        //        guard ringtone.identifier != nil else { return nil }
        self.ringtone = ringtone
    }
    
    func assignDefaultRingtone() {
        if !ringtone.installed {
            BFLog("ringtone not install in assigner, installing before assigning")
            RingtoneManager.installRingtone(ringtoneObject: ringtone, useHUD: false) {
                TLToneManagerHandler.sharedInstance().setCurrentToneIdentifier(self.ringtone.identifier, forAlertType: 1)
            }
        } else {
            TLToneManagerHandler.sharedInstance().setCurrentToneIdentifier(ringtone.identifier, forAlertType: 1)
        }
    }
    
    func assignDefaultRingtone(forContact: CNContact) {
        if !ringtone.installed {
            BFLog("ringtone not install in assigner, installing before assigning")
            RingtoneManager.installRingtone(ringtoneObject: ringtone, useHUD: false) {
                
                if CNMutableContactHandler.init(contact: forContact).setCallAlert(self.ringtone.identifier) {
                    HUD.flash(.label("Set ringtone to contact successfully"), delay: 1.0)
                } else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when setting ringtone to contact"), delay: 1.0)
                    Bugfender.error("Got false from setCallAlert on contact")
                }
            }
        } else {
            if CNMutableContactHandler.init(contact: forContact).setCallAlert(self.ringtone.identifier) {
                HUD.flash(.label("Set ringtone to contact successfully"), delay: 1.0)
            } else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when setting ringtone to contact"), delay: 1.0)
                Bugfender.error("Got false from setCallAlert on contact")
            }
        }
    }
    
    func assignDefaultTextTone() {
        if !ringtone.installed {
            BFLog("ringtone not install in assigner, installing before assigning")
            RingtoneManager.installRingtone(ringtoneObject: ringtone, useHUD: false) {
                
                TLToneManagerHandler.sharedInstance().setCurrentToneIdentifier(self.ringtone.identifier, forAlertType: 2)
            }
        } else {
            TLToneManagerHandler.sharedInstance().setCurrentToneIdentifier(self.ringtone.identifier, forAlertType: 2)
        }
    }
    
    func assignDefaultTextTone(forContact: CNContact) {
        if !ringtone.installed {
            BFLog("ringtone not install in assigner, installing before assigning")
            RingtoneManager.installRingtone(ringtoneObject: ringtone, useHUD: false) {
                
                if CNMutableContactHandler.init(contact: forContact).setTextAlert(self.ringtone.identifier) {
                    HUD.flash(.label("Set text tone to contact successfully"), delay: 1.0)
                } else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when setting text tone to contact"), delay: 1.0)
                    Bugfender.error("Got false from setTextAlert on contact")
                }
            }
        } else {
            if CNMutableContactHandler.init(contact: forContact).setTextAlert(self.ringtone.identifier) {
                HUD.flash(.label("Set text tone to contact successfully"), delay: 1.0)
            } else {
                HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when setting text tone to contact"), delay: 1.0)
                Bugfender.error("Got false from setTextAlert on contact")
            }
        }
    }
}


