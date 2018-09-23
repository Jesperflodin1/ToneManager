//
//  HelpData.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-23.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

class HelpItem {
    
    var title: String?
    var text: String?
    var textShown = false
    
    init(title: String, text: String) {
        self.title = title
        self.text = text
    }
    
}
