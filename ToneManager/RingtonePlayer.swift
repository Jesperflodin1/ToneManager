//
//  RingtonePlayer.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-13.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import AVFoundation
import BugfenderSDK

/// Class that handles playing of ringtones
class RingtonePlayer {
    
    /// Ringtone object that currently is playing
    var ringtone : Ringtone?
    
    /// AVAudioPlayer object, used for playing audio
    var audioPlayer : AVAudioPlayer?
    
    /// Bool that describes if this object is currently playing audio
    var isPlaying : Bool = false
    
    /// Init method. Takes a ringtone object as parameter
    ///
    /// - Parameter ringtone: ringtone to play
    init(ringtone : Ringtone) {
        self.ringtone = ringtone
    }
    
    /// Starts playing ringtone if ringtone variable is set
    func playRingtone() {
        guard let ringtone = self.ringtone else { return }
        
        let url = ringtone.fileURL
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // For iOS 11
            if #available(iOS 11.0, *) {
                self.audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.m4a.rawValue)
            } else { // For iOS versions < 11
                self.audioPlayer = try AVAudioPlayer(contentsOf: url)
            }

            guard let aPlayer = audioPlayer else { return }
            aPlayer.play()
            
        } catch {
            Bugfender.error("Error when playing ringtone: \(ringtone) with error: \(error)")
        }

        self.isPlaying = true
    }
    
    /// Stops playing ringtone
    func stopPlaying() {
        
        
        
        
        
        self.isPlaying = false
    }
    
}
