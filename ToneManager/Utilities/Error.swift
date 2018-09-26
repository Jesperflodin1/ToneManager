//
//  ErrorCode.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-19.
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
