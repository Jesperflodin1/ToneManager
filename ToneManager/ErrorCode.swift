//
//  ErrorCode.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-19.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

public enum ErrorCode: Int {
    case invalidRingtoneFile = 9001
    case invalidRingtoneFileExtension = 9002
    case invalidRingtoneFileContent = 9003
    
    case unknownImportError = 9004
}
