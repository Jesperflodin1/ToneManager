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


//**** Warning: The following might make your eyes bleed...


import Foundation

class HelpData {
    
    static func getHelpData() -> [HelpItem] {
        var data = [HelpItem]()
        
        let lineBreak = NSAttributedString(string: "\n")
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
        
        
        let audiko0Attachment = NSTextAttachment()
        audiko0Attachment.image = UIImage(named: "audiko0")
        audiko0Attachment.setImageHeight(height: 90)
        let audiko1Attachment = NSTextAttachment()
        audiko1Attachment.image = UIImage(named: "audiko1")
        audiko1Attachment.setImageHeight(height: 120)
        let audiko0AttString = NSAttributedString(attachment: audiko0Attachment)
        let audiko1AttString = NSAttributedString(attachment: audiko1Attachment)
        
        let audiko = NSMutableAttributedString()
        audiko.append(bulletPointList(strings: ["Tap the ringtone you want"]))
        audiko.append(lineBreak+lineBreak)
        audiko.append(audiko0AttString)
        audiko.append(lineBreak)
        audiko.append(bulletPointList(strings: ["Tap the red button that says add to favorites or similar (depending on your device language)"]))
        audiko.append(lineBreak+lineBreak)
        audiko.append(audiko1AttString)
        audiko.append(lineBreak)
        data.append(HelpItem(title: "How to import ringtones from Audiko", attributedText: audiko))
        
        
        
        let zedgeAttachment = NSTextAttachment()
        zedgeAttachment.image = UIImage(named: "zedge0")
        zedgeAttachment.setImageHeight(height: 90)
        let zedge = NSMutableAttributedString()
        let zedgeAttString = NSAttributedString(attachment: zedgeAttachment)
        zedge.append(bulletPointList(strings: [
            "Choose a ringtone in zedge",
            "Tap download button"]))
        zedge.append(lineBreak+lineBreak)
        zedge.append(zedgeAttString)
        zedge.append(lineBreak)
        zedge.append(bulletPointList(strings: [
            "Open ToneManager and the ringtone should import and install (if automatic installation is enabled in settings for this app)"]))
        data.append(HelpItem(title: "How to import ringtones from Zedge", attributedText: zedge))
        
        
        
        let filebrowser0Attachment = NSTextAttachment()
        filebrowser0Attachment.image = UIImage(named: "filebrowser0")
        filebrowser0Attachment.setImageHeight(height: 170)
        let filebrowser = NSMutableAttributedString()
        let filebrowserAttString = NSAttributedString(attachment: filebrowser0Attachment)
        filebrowser.append(bulletPointList(strings: [
            "Tap the folder button in the toolbar",
            "Navigate to the file you want to import",
            "Tap it and the file should import. If it's not an m4r file, the app will try to convert it first."]))
        filebrowser.append(lineBreak+lineBreak)
        filebrowser.append(filebrowserAttString)
        filebrowser.append(lineBreak)
        
        data.append(HelpItem(title: "How to import ringtone file from filesystem", attributedText: filebrowser))
        
        
        
        
        let filza0Attachment = NSTextAttachment()
        filza0Attachment.image = UIImage(named: "filza0")
        filza0Attachment.setImageHeight(height: 130)
        let filza1Attachment = NSTextAttachment()
        filza1Attachment.image = UIImage(named: "filza1")
        filza1Attachment.setImageHeight(height: 130)
        let filza2Attachment = NSTextAttachment()
        filza2Attachment.image = UIImage(named: "filza2")
        filza2Attachment.setImageHeight(height: 250)
        let filza = NSMutableAttributedString()
        let filza0AttString = NSAttributedString(attachment: filza0Attachment)
        let filza1AttString = NSAttributedString(attachment: filza1Attachment)
        let filza2AttString = NSAttributedString(attachment: filza2Attachment)

        filza.append(NSAttributedString(string: "This will also apply to most other file manager apps you may have. \n", attributes: [.paragraphStyle:paragraphStyle]))
        filza.append(bulletPointList(strings: [
            "Navigate to the ringtone file (m4r file or a format this app can convert to m4r) you want to import.",
            "Tap it and tap the share button"]))
        filza.append(lineBreak+lineBreak)
        filza.append(filza0AttString)
        filza.append(lineBreak+lineBreak)
        filza.append(filza1AttString)
        filza.append(lineBreak)
        filza.append(bulletPointList(strings: [
            "Tap Tonemanager in the Open with menu that shows up. The ringtone should import and also install (if automatic installation is enabled in settings for this app)"]))
        filza.append(lineBreak+lineBreak)
        filza.append(filza2AttString)
        filza.append(lineBreak)
        data.append(HelpItem(title: "How to import ringtone file with Filza", attributedText: filza))
        
        
        
        let voice0Attachment = NSTextAttachment()
        voice0Attachment.image = UIImage(named: "voice0")
        voice0Attachment.setImageHeight(height: 180)
        let voice1Attachment = NSTextAttachment()
        voice1Attachment.image = UIImage(named: "voice1")
        voice1Attachment.setImageHeight(height: 230)
        let voice0AttString = NSAttributedString(attachment: voice0Attachment)
        let voice1AttString = NSAttributedString(attachment: voice1Attachment)
        let voice = NSMutableAttributedString()
        voice.append(bulletPointList(strings: [
            "Record whatever you want and tap the share button for the recording you want to import",
            "The length should be less than 30 seconds, if longer it will be modified on import so only the first 30 seconds are included"]))
        voice.append(lineBreak+lineBreak)
        voice.append(voice0AttString)
        voice.append(lineBreak)
        voice.append(bulletPointList(strings: [
            "Choose ToneManager in the Open in menu that shows up",
            "The recording should import and install (if automatic installation is enabled in settings for this app)"]))
        voice.append(lineBreak+lineBreak)
        voice.append(voice1AttString)
        voice.append(lineBreak)

        data.append(HelpItem(
            title: "How to import ringtone from built-in voice recorder",
            attributedText: voice))
        
        
        
        
        let setdefault0Attachment = NSTextAttachment()
        setdefault0Attachment.image = UIImage(named: "setdefault0")
        setdefault0Attachment.setImageHeight(height: 70)
        let setdefault1Attachment = NSTextAttachment()
        setdefault1Attachment.image = UIImage(named: "setdefault1")
        setdefault1Attachment.setImageHeight(height: 260)
        let setdefault0AttString = NSAttributedString(attachment: setdefault0Attachment)
        let setdefault1AttString = NSAttributedString(attachment: setdefault1Attachment)
        let setDefault = NSMutableAttributedString()
        
        setDefault.append(bulletPointList(strings: [
            "Tap the menu button on the ringtone you want to import"]))
        setDefault.append(lineBreak+lineBreak)
        setDefault.append(setdefault0AttString)
        setDefault.append(lineBreak)
        setDefault.append(bulletPointList(strings: [
            "Tap assign to contact to get a window where you can choose a contact to assign it to, then choose either to apply it as ringtone or text tone in the menu that shows up",
            "You can do the same by opening the ringtone details page in the same menu or tap the Info button on the row for the ringtone. There you will get the same assign as options as in this menu"]))
        setDefault.append(lineBreak+lineBreak)
        setDefault.append(setdefault1AttString)
        setDefault.append(lineBreak)
        
        
        let fileTypes = ["m4r", "wav", "aif", "caf", "mp3", "mp4", "snd", "au", "sd2", "aiff", "aifc", "aac"]
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
