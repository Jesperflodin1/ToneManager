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
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.minimumLineHeight = 22
        paragraphStyle.maximumLineHeight = 22
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        let cantStrings = [
            "This is not a ringtone downloader. It will not download ringtones for you. Use Audiko, zedge or something else that allows you to download ringtones",
            "This app cant help you create your own ringtones from music on your iphone. However, you can import music files and you will get a ringtone which includes the first 30 seconds of sound from the imported file. This might change in the future"]
        data.append(HelpItem(title: "What this app CAN'T do", attributedText: bulletPointList(strings: cantStrings)))
        
        let canStrings = [
            "Install ringtones from Audiko, Zedge, other ringtone apps, music files or ringtone files on your filesystem without using iTunes on a computer",
            "Set imported ringtones as default ringtone, default text tone or assign them to a contact",
            "Convert other sound files to ringtones"]
        data.append(HelpItem(title: "What this app CAN do", attributedText: bulletPointList(strings: canStrings)))
        
        
        //TODO: image
        data.append(HelpItem(title: "How to import ringtones from Audiko", text: "PLACEHOLDER: How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko"))
        
        //TODO: image
        data.append(HelpItem(title: "How to import ringtones from Zedge", text: "PLACEHOLDER: How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko"))
        
        //TODO: Image
        data.append(HelpItem(title: "How to import ringtone file from filesystem", text: "PLACEHOLDER: How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko How to import ringtones from Audiko"))
        
        
        let filzaImport = [
            "Navigate to the ringtone file (m4r file or a format this app can convert to m4r) you want to import.",
            "Tap it and tap the share button",
            "Tap Tonemanager in the Open in menu that shows up. The ringtone should import and also install (if automatic installation is enabled in settings for this app)"]
        data.append(HelpItem(
title: "How to import ringtone file with Filza",
attributedText: NSAttributedString(string: "This will also apply to most other file manager app you may have. \n ", attributes: [.paragraphStyle:paragraphStyle]) + bulletPointList(strings: filzaImport) ))
        
        //TODO: Image
        let voiceStrings = [
            "Record whatever you want and tap the share button for the recording you want to import",
            "The length should be less than 30 seconds, if longer it will be modified on import so only the first 30 seconds are included",
            "Choose ToneManager in the Open in menu that shows up",
            "The recording should import and install (if automatic installation is enabled in settings for this app)"]
        data.append(HelpItem(
            title: "How to import ringtone from built-in voice recorder",
            attributedText: bulletPointList(strings: voiceStrings)))
        
        
        let fileTypes = ["wav", "aif", "caf", "mp3", "mp4", "snd", "au", "sd2", "aiff", "aifc", "aac"]
        data.append(HelpItem(
            title: "File formats this app can convert to ringtones",
            attributedText: NSAttributedString(string: "You need to do a manual import using the built-in filebrowser or 'open in' from another app. The following file types can be converted by this app: \n", attributes: [.paragraphStyle:paragraphStyle]) + bulletPointList(strings: fileTypes) ))
        
        data.append(HelpItem(title: "Can this app be sideloaded on a non-jailbroken iphone?", attributedText: NSAttributedString(string: "No. The private frameworks this app uses also requires private entitlements. As far as i know it is not possible to set these entitlements without a jailbreak.", attributes: [.paragraphStyle:paragraphStyle])))
        
        
        data.append(HelpItem(title: "Found a bug? Have another problem or a suggestion?", attributedText: NSAttributedString(string: "Use the email button in settings in this app or create an issue on github. The email button will create an email with several useful files that include your current settings, imported ringtones and values associated with them, version of this app, your iOS version, device model and a device identifier which helps me find logs from your device.", attributes: [.paragraphStyle:paragraphStyle])))
        
        return data
    }
    
    static func bulletPointList(strings: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.minimumLineHeight = 22
        paragraphStyle.maximumLineHeight = 22
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: 15)]
        
        let stringAttributes = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12),
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.paragraphStyle: paragraphStyle
        ]
        
        let string = strings.map({ "•\t\($0)" }).joined(separator: "\n")
        
        return NSAttributedString(string: string,
                                  attributes: stringAttributes)
    }
}
