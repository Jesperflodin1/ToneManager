//
//  RingtonePlayer.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import AVFoundation
import BugfenderSDK

final class RingtonePlayer: NSObject {
    /// AVAudioPlayer object, used for playing audio
    var audioPlayer : AVAudioPlayer?
    
    weak var tableView : UITableView?
    
    init(inTableView tableView : UITableView) {
        self.tableView = tableView
    }
    
    var setupDone : Bool {
        guard self.audioPlayer != nil else { return false }
        return true
    }
}

//MARK: Play/stop controls
extension RingtonePlayer {
    func setupPlayer(ringtone: Ringtone) -> Bool {
        if setupDone {
            stopPlaying()
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // For iOS 11
            if #available(iOS 11.0, *) {
                self.audioPlayer = try AVAudioPlayer(contentsOf: ringtone.fileURL, fileTypeHint: AVFileType.m4a.rawValue)
            } else { // For iOS versions < 11
                self.audioPlayer = try AVAudioPlayer(contentsOf: ringtone.fileURL)
            }
            self.audioPlayer?.prepareToPlay()
            self.audioPlayer?.delegate = self
            return true
        } catch {
            Bugfender.error("Error when preparing to play ringtone: \(ringtone) with error: \(error)")
            return false
        }
    }
    
    /// Starts playing ringtone if ringtone variable is set
    func playRingtone() {
        guard let player = self.audioPlayer else { return }
        guard let tableView = tableView else { return }
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPathForSelectedRow) as? RingtoneTableCell {
                cell.playButton.setImage(ColorPalette.ringtoneCellStopImage, for: .normal)
                player.play()
            }
        }
    }
    
    /// Stops playing ringtone
    func stopPlaying() {
        guard let player = self.audioPlayer else { return }
        guard let tableView = tableView else { return }
        
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow {
            if let cell = tableView.cellForRow(at: indexPathForSelectedRow) as? RingtoneTableCell {
                cell.playButton.setImage(ColorPalette.ringtoneCellPlayImage, for: .normal)
                player.stop()
                self.audioPlayer = nil
            }
        }
    }
    
    func togglePlayForSelectedRingtone() {
        guard let tableView = tableView else { return }
        
        if let indexPath = tableView.indexPathForSelectedRow {
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            guard let ringtone = cell.ringtoneItem else { return }
            
            
            
            //if not prepared with ringtone, setup/prepare
            if !setupDone {
                guard setupPlayer(ringtone: ringtone) else { return }
            }
            
            if (audioPlayer?.isPlaying)! {
                stopPlaying()
            } else {
                playRingtone()
            }
        }
    }
}

//MARK: AVAudioPlayerDelegate
extension RingtonePlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Bugfender.warning("Audio playback error: \(String(describing: error))")
        stopPlaying()
        audioPlayer = nil
    }
}
