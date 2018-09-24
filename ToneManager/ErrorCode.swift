//
//  ErrorCode.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-19.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

enum ErrorCode: Int {
    case invalidRingtoneFile = 9001
    case invalidRingtoneFileExtension = 9002
    case invalidRingtoneFileContent = 9003
    
    case fileAlreadyImported = 8001
    case copyFailure = 8002
    
    case unknownImportError = 9004
}

enum ErrorDomain: String {
    
    case ringtoneFileImporter = "fi.flodin.tonemanager.RingtoneFileImporter"
    case ringtoneStore = "fi.flodin.tonemanager.RingtoneStore"
}
