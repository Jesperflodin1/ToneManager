//
//  HelpData.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-23.
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

class HelpData {
    
    static func getHelpData() -> [HelpItem] {
        var data = [HelpItem]()
        
        data.append(HelpItem(title: "How to import ringtones from Audiko", text: "How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko"))
        
        data.append(HelpItem(title: "How to import ringtones from Zedge", text: "How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko"))
        
        data.append(HelpItem(title: "How to import ringtone file from filesystem", text: "How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko"))
        
        data.append(HelpItem(
title: "How to import ringtone file with Filza",
text: "This will also apply to any other file manager app you may have. \n Navigate to the ringtone file (preferably a m4r file) you want to import. Tap it and tap the share button. Tap Tonemanager in the Open in menu that shows up. The ringtone should import and also install (if automatic installation is enabled in settings for this app)"))
        
        data.append(HelpItem(
            title: "How to import ringtone from built-in sound recorder",
            text: "Record whatever you want and tap the share button for the recording you want to import. The length should be less than 30 seconds. Choose ToneManager in the Open in menu that shows up. The recording should import and install (if automatic installation is enabled in settings for this app)"))
        
        
        return data
    }
}
