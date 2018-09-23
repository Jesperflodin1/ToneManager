//
//  RingtoneConverter.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-23.
//  Based on AudioKit: https://github.com/AudioKit/AudioKit/blob/master/AudioKit/Common/Internals/AKConverter.swift
//

import AVFoundation
import BugfenderSDK

/**
 AKConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
 ```
 let options = AKConverter.Options()
 // any options left nil will assume the value of the input file
 options.format = "wav"
 options.sampleRate == 48000
 options.bitDepth = 24
 let converter = AKConverter(inputURL: oldURL, outputURL: newURL, options: options)
 converter.start(completionHandler: { error in
 // check to see if error isn't nil, otherwise you're good
 })
 ```
 */
class RingtoneConverter: NSObject {
    /**
     RingtoneConverterCallback is the callback format for start()
     -Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
     */
    public typealias RingtoneConverterCallback = (_ error: Error?) -> Void
    
    /** Formats that this class can write */
    public static let outputFormats = ["m4a", "m4r"]
    
    /** Formats that this class can read */
    public static let inputFormats = RingtoneConverter.outputFormats + ["wav", "aif", "caf", "mp3", "mp4", "snd", "au", "sd2", "aiff", "aifc", "aac"]
    
    /**
     The conversion options, leave nil to adopt the value of the input file
     */
    public struct Options {
        public init() {}
        public var format: String?
        public var sampleRate: Double?
        /// used only with PCM data
        public var bitDepth: UInt32?
        /// used only when outputting compressed from PCM
        public var bitRate: UInt32 = 256_000
        public var channels: UInt32?
        public var isInterleaved: Bool?
        /// overwrite existing files, set false if you want to handle this before you call start()
        public var eraseFile: Bool = true
    }
    
    // MARK: - public properties
    open var inputURL: URL?
    open var outputURL: URL?
    open var options: Options?
    
    // MARK: - private properties
    // The reader needs to exist outside the start func otherwise the async nature of the
    // AVAssetWriterInput will lose its reference
    private var reader: AVAssetReader?
    
    // MARK: - initialization
    /// init with input, output and options - then start()
    public init(inputURL: URL, outputURL: URL, options: Options? = nil) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.options = options
    }
    
    // MARK: - public functions
    /**
     The entry point for file conversion
     - Parameter completionHandler: the callback that will be triggered when process has completed.
     */
    open func start(completionHandler: RingtoneConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }
        
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }
        
        let inputFormat = inputURL.pathExtension.lowercased()
        // verify inputFormat
        guard RingtoneConverter.inputFormats.contains(inputFormat) else {
            completionHandler?(createError(message: "The input file format isn't able to be processed."))
            return
        }
        
        // Format checks are necessary as AVAssetReader has opinions about compressed audio for some illogical reason
        if isCompressed(url: inputURL) && isCompressed(url: outputURL) {
            convertCompressed(completionHandler: completionHandler)
            return
        }
        
        convertAsset(completionHandler: completionHandler)
    }
    
    // MARK: - private helper functions
    // The AVFoundation way
    private func convertAsset(completionHandler: RingtoneConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }
        
        let outputFormat = options?.format ?? outputURL.pathExtension.lowercased()
        
        // verify outputFormat
        guard RingtoneConverter.outputFormats.contains(outputFormat) else {
            completionHandler?(createError(message: "The output file format isn't able to be produced by this class."))
            return
        }
        
        let asset = AVAsset(url: inputURL)
        do {
            reader = try AVAssetReader(asset: asset)
            
        } catch let err as NSError {
            completionHandler?(err)
            return
        }
        
        guard let reader = reader else {
            completionHandler?(createError(message: "Unable to setup the AVAssetReader."))
            return
        }
        
        var inputFile: AVAudioFile
        do {
            inputFile = try AVAudioFile(forReading: inputURL)
        } catch let err as NSError {
            // Error creating input audio file
            completionHandler?(err)
            return
        }
        
        if options == nil {
            options = Options()
        }
        
        guard let options = options else {
            completionHandler?(createError(message: "The options are malformed."))
            return
        }
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            if options.eraseFile {
                try? FileManager.default.removeItem(at: outputURL)
            } else {
                let message = "The output file exists already. You need to choose a unique URL or delete the file."
                let err = createError(message: message)
                completionHandler?(err)
                return
            }
        }
        
        let format: AVFileType = .m4a
        let formatKey: AudioFormatID = kAudioFormatMPEG4AAC
        
        var writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: format)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }
        
        var sampleRate = options.sampleRate ?? inputFile.fileFormat.sampleRate
        let channels = options.channels ?? inputFile.fileFormat.channelCount
        
        // Note: AVAssetReaderOutput does not currently support compressed output
            
        if sampleRate > 48_000 {
            sampleRate = 44_100
        }
        
        let outputSettings : [String:Any] = [
            AVFormatIDKey: formatKey,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVEncoderBitRateKey: options.bitRate
        ]
        
        
        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: outputSettings)
        writer.add(writerInput)
        
        let tracks = asset.tracks(withMediaType: .audio)
        
        guard !tracks.isEmpty else {
            completionHandler?(createError(message: "No audio was found in the input file."))
            return
        }
        
        let readerOutput = AVAssetReaderTrackOutput(track: tracks[0], outputSettings: nil)
        reader.add(readerOutput)
        
        if !writer.startWriting() {
            let error = String(describing: writer.error)
            BFLog("Failed to start writing. Error: \(error)")
            completionHandler?(writer.error)
            return
        }
        
        writer.startSession(atSourceTime: kCMTimeZero)
        reader.startReading()
        
        let queue = DispatchQueue(label: "io.audiokit.AKConverter.start", qos: .utility)
        
        writerInput.requestMediaDataWhenReady(on: queue, using: {
            while writerInput.isReadyForMoreMediaData {
                
                if reader.status == .failed {
                    BFLog("Conversion Failed")
                    break
                }
                
                if let buffer = readerOutput.copyNextSampleBuffer() {
                    writerInput.append(buffer)
                    
                } else {
                    writerInput.markAsFinished()
                    writer.endSession(atSourceTime: asset.duration)
                    writer.finishWriting {
                        // BFLog("DONE: \(self.reader!.asset)")
                        DispatchQueue.main.async {
                            completionHandler?(nil)
                        }
                    }
                }
            }
        }) // requestMediaDataWhenReady
    }
    
    // Example of the most simplistic AVFoundation conversion.
    // With this approach you can't really specify any settings other than the limited presets.
    private func convertCompressed(completionHandler: RingtoneConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }
        
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        
        let asset = AVURLAsset(url: inputURL)
        
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }
        session.outputURL = outputURL
        session.outputFileType = AVFileType.m4a
        session.timeRange = CMTimeRange(start: kCMTimeZero, duration: CMTimeMakeWithSeconds(30, 600))
        session.exportAsynchronously {
            completionHandler?(session.error)
        }
    }
    
    private func isCompressed(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return (ext == "m4a" || ext == "m4r" || ext == "mp3" || ext == "mp4")
    }
    
    private func createError(message: String, code: Int = 1) -> NSError {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "fi.flodin.tonemanager.RingtoneConverter.error", code: code, userInfo: userInfo)
    }
}
