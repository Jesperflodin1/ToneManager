//
//  RingtoneConverter.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-23.
//  Based on AudioKit: https://github.com/AudioKit/AudioKit/blob/master/AudioKit/Common/Internals/AKConverter.swift
//

import AVFoundation
import BugfenderSDK

class RingtoneConverter: NSObject {
    /**
     RingtoneConverterCallback is the callback format for start()
     -Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
     */
    public typealias RingtoneConverterCallback = (_ error: Error?) -> Void
    
    /** Formats that this class can write */
    public static let outputFormats = ["m4a"]
    
    /** Formats that this class can read */
    public static let inputFormats = RingtoneConverter.outputFormats + ["wav", "aif", "caf", "mp3", "mp4", "snd", "au", "sd2", "aiff", "aifc", "aac"]
    
    // MARK: - public properties
    open var inputURL: URL?
    open var outputURL: URL?

    
    // MARK: - private properties
    // The reader needs to exist outside the start func otherwise the async nature of the
    // AVAssetWriterInput will lose its reference
    private var reader: AVAssetReader?
    
    // MARK: - initialization
    /// init with input, output - then start()
    public init(inputURL: URL, outputURL: URL) {
        self.inputURL = inputURL
        if outputURL.pathExtension == "m4r" {
            self.outputURL = outputURL.deletingPathExtension().appendingPathExtension("m4a")
            BFLog("Converter called with extension: \(outputURL.pathExtension), but im really using: \(outputURL.deletingPathExtension().appendingPathExtension("m4a"))")
        } else {
            self.outputURL = outputURL
        }
    }
    
    // MARK: - public functions
    /**
     The entry point for file conversion
     - Parameter completionHandler: the callback that will be triggered when process has completed.
     */
    open func start(completionHandler: RingtoneConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(domain: .ringtoneConverter, message: "Input file can't be nil.", code: .nilFileURL))
            return
        }
        
        let inputFormat = inputURL.pathExtension.lowercased()
        // verify inputFormat
        guard RingtoneConverter.inputFormats.contains(inputFormat) else {
            completionHandler?(createError(domain: .ringtoneConverter, message: "The input file format isn't able to be processed.", code: .invalidFormat))
            return
        }

        convert(completionHandler: completionHandler)

    }
    
    
    // Example of the most simplistic AVFoundation conversion.
    // With this approach you can't really specify any settings other than the limited presets.
    private func convert(completionHandler: RingtoneConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(domain: .ringtoneConverter, message: "Input file can't be nil.", code: .nilFileURL))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(domain: .ringtoneConverter, message: "Output file can't be nil.", code: .nilFileURL))
            return
        }
        
        if FileManager.default.fileExists(atPath: outputURL.deletingPathExtension().appendingPathExtension("m4a").path) {
            try? FileManager.default.removeItem(at: outputURL.deletingPathExtension().appendingPathExtension("m4a"))
        }
        if FileManager.default.fileExists(atPath: outputURL.deletingPathExtension().appendingPathExtension("m4r").path) {
            try? FileManager.default.removeItem(at: outputURL.deletingPathExtension().appendingPathExtension("m4r"))
        }
        
        let asset = AVURLAsset(url: inputURL)
        
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }
        session.outputURL = outputURL
        session.outputFileType = AVFileType.m4a
        session.timeRange = CMTimeRange(start: kCMTimeZero, duration: CMTimeMakeWithSeconds(30, 600))
        session.exportAsynchronously {
            if session.error == nil {
                let newURL = outputURL.deletingPathExtension().appendingPathExtension("m4r")
                do {
                    try FileManager.default.moveItem(at: outputURL, to: newURL)
                } catch {
                    Bugfender.error("Error when changing file extension, error: \(error as NSError)")
                }
            } else {
                if let error = session.error {
                    Bugfender.error("Error during file conversion: \(error as NSError)")
                }
            }
            completionHandler?(session.error)
        }
    }
}
