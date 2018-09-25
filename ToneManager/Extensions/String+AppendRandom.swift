//
//  String+AppendRandom.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

extension String {
    /// Appends 4 random characters with whitespace to the end of the string
    mutating func appendRandom() {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""
        
        let length = 4
        
        for _ in 0..<length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }
        
        self += String(format: " %@", randomString)
    }
}
