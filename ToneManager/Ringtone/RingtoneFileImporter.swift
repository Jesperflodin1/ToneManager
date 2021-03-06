//
//  RingtoneFileImporter.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
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
import FileBrowser
import BugfenderSDK
import AVFoundation


final class RingtoneFileImporter: RingtoneScanner {
    
    
    
    /// Serial queue for file importer tasks
    fileprivate let queue = DispatchQueue(label: "fi.flodin.tonemanager.FileImporterQueue")
    
    let knownExtensions = ["m4r"]
    let convertExtensions = ["wav", "aif", "caf", "mp3", "mp4", "snd", "au", "sd2", "aiff", "aifc", "aac", "m4a"]
    
    var importError : NSError? = nil
    
    
    
    fileprivate func convertFileAndImport(at file : URL, completionHandler: @escaping (Bool, Ringtone?) -> ()) {
        BFLog("File is not valid m4r ringtone, calling convert for: %@", file.path)
        
        var sourceURL = file
        let outputFolder = appDataDir.appendingPathComponent("tmp", isDirectory: true) //TODO: Clear tmp folder
        do {
            try FileManager.default.createDirectory(at: outputFolder, withIntermediateDirectories: true)
            if file.m4r() {
                // since we cant be sure that source is writable, move to tmp and change file extension to fool AVFoundation
                // set sourceurl to appdata/tmp/converting/file.m4a and move there
                sourceURL = outputFolder.appendingPathComponent("converting", isDirectory: true).appendingPathComponent(file.changingPathExtension("m4a").lastPathComponent, isDirectory: false)
                
                try FileManager.default.createDirectory(at: outputFolder.appendingPathComponent("converting", isDirectory: true), withIntermediateDirectories: true)
                try FileManager.default.copyItem(at: file, to: sourceURL)
            }
        } catch {
            BFLog("Temp folder already exists? Error when creating temp folder: %@", error as NSError)
        }
        // Make sure we get a m4r file
        let outputURL = outputFolder.appendingPathComponent(sourceURL.changingPathExtension("m4r").lastPathComponent, isDirectory: false)
        
        let converter = RingtoneConverter(inputURL: sourceURL, outputURL: outputURL)
        converter.start(completionHandler: { (error) in
            if let convertError = error {
                Bugfender.error("Got error from file converter: \(convertError as NSError)")
                self.importError = convertError as NSError
                completionHandler(false, nil)
            } else {
                //converter will always output m4r file
                BFLog("File converter success")
                if let tone = self.importm4r(outputURL) {
                    completionHandler(true, tone)
                } else {
                    completionHandler(false, nil)
                }
                
            }
        })
    }
    
    func importFile(_ file : URL, completionHandler: @escaping (Bool, Ringtone?) -> ()) {
        queue.async {
            BFLog("Trying to import file")
            if !self.isURLValidRingtone(file) {
                Bugfender.warning("File is not valid ringtone, got extension: \(file.pathExtension)")
//                self.importError = createError(domain: .ringtoneFileImporter, message: "File is not a valid ringtone", code: .invalidRingtoneFile)
                completionHandler(false, nil)
                return
            }
            BFLog("File is valid ringtone, got extension: %@", file.pathExtension)
            
            // m4r shorter than 31 seconds, else convert to 30 seconds
            let duration = file.audioDurationOfFile()
            BFLog("Got duration: %d", duration)
            
            if file.m4r(), duration <= 31 {
                BFLog("File is m4r, calling import: %@", file.path)
                if let tone = self.importm4r(file) {
                    completionHandler(true, tone)
                } else {
                    completionHandler(false, nil)
                }
            } else {
                self.convertFileAndImport(at: file, completionHandler: completionHandler)
            }
        }
    }
    
    
    
    fileprivate func importm4r(_ fileURL : URL) -> Ringtone? {
        guard let currentApp = Bundle.main.bundleIdentifier else { return nil }
        
        var appendRandomToRingtoneName : Bool = false
        
        // Skip ringtones with same filename from same app
        if (RingtoneStore.sharedInstance.allRingtones.contains(where: { ($0.fileURL.lastPathComponent ==  fileURL.lastPathComponent) && ($0.bundleID == currentApp) } )) {
            BFLog("File already exists: %@ for app: %@", fileURL.path, currentApp)
            importError = createError(domain: .ringtoneFileImporter, message: "File already imported", code: .fileAlreadyImported)
            return nil
        }
        
        // if filename already exists, but different app, prepare to set a different ringtone name
        if (RingtoneStore.sharedInstance.allRingtones.contains(where: { $0.fileURL.lastPathComponent ==  fileURL.lastPathComponent } )) {
            BFLog("File already exists but different app, importing anyway: %@", fileURL.path)
            appendRandomToRingtoneName = true
        }
        
        guard let path = copyRingtoneToApp(fileURL.path, forBundleID: currentApp) else {
            Bugfender.error("Error when getting new filepath for ringtone at path: \(fileURL.path)")
            importError = NSError(domain: ErrorDomain.ringtoneFileImporter.rawValue, code: ErrorCode.copyFailure.rawValue, userInfo: nil)
            return nil
        }
        
        let newRingtone = Ringtone(filePath: path, bundleID: currentApp, appendRandomToName: appendRandomToRingtoneName)
        return newRingtone
    }
    
    func isFileValidRingtone(_ file : FBFile) -> Bool {
        BFLog("is file valid called")
        if file.isDirectory { return false }
        
        return isURLValidRingtone(file.filePath)
    }
    
    func isURLValidRingtone(_ fileURL : URL) -> Bool {
        BFLog("is fileurl valid called, got extension: %@", fileURL.pathExtension)
        
        if !knownExtensions.contains(fileURL.pathExtension), !convertExtensions.contains(fileURL.pathExtension) {
            importError = createError(domain: .ringtoneFileImporter, message: "Unknown file extension", code: .invalidRingtoneFileExtension)
            return false
        }
        
        do
        {
            let attribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attribute[FileAttributeKey.size] as? Int {
                if size < 1 {
                    importError = createError(domain: .ringtoneFileImporter, message: "No file content", code: .invalidRingtoneFileContent)
                    return false
                }
            }
        }
        catch{
            Bugfender.error("Error when retrieving size of file: %@, error: %@", fileURL, error)
            importError = error as NSError
            return false
        }
        
        return true
    }
}
