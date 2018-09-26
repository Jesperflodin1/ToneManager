//
//  NSAttributedString+Concatenate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-26.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

extension NSAttributedString {
    // concatenate attributed strings
    static func + (left: NSAttributedString, right: NSAttributedString) -> NSAttributedString
    {
        let result = NSMutableAttributedString()
        result.append(left)
        result.append(right)
        return result
    }
}
