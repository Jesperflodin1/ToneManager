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
    
    case nilFileURL = 7001
    case invalidFormat = 7002
    
    case unknownImportError = 9004
    
    case unknownError = 1001
}

enum ErrorDomain: String {
    
    case ringtoneFileImporter = "fi.flodin.tonemanager.RingtoneFileImporter"
    case ringtoneStore = "fi.flodin.tonemanager.RingtoneStore"
    case ringtoneConverter = "fi.flodin.tonemanager.RingtoneConverter"
    
    case defaultDomain = "fi.flodin.tonemanager"
}

func createError(domain: ErrorDomain = .defaultDomain, message: String, code: ErrorCode = .unknownError) -> NSError {
    let userInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
    return NSError(domain: domain.rawValue, code: code.rawValue, userInfo: userInfo)
}
