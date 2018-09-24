//
//  HelpData.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-23.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

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
