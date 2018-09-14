//
//  RingtoneDetailViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-08.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import AVFoundation
import BugfenderSDK

/// View controller that shows details page for ringtone
class RingtoneDetailViewController : UITableViewController, AVAudioPlayerDelegate {
    
    /// Outlet for ringtone name label
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Outlet for label that show which app it was imported from.
    @IBOutlet weak var appLabel: UILabel!
    
    /// Outlet for ringtone length label
    @IBOutlet weak var lengthLabel: UILabel!
    
    /// Outlet for file size label
    @IBOutlet weak var sizeLabel: UILabel!
    
    /// Outlet for ringtone path label
    @IBOutlet weak var pathLabel: UILabel!
    
    /// Outlet for duration label in ringtone player
    @IBOutlet weak var ringtonePlayerDurationLabel: UILabel!
    
    /// Outlet for image left of play label
    @IBOutlet weak var ringtonePlayerPlayImage: UIImageView!
    
    /// Outlet for play label
    @IBOutlet weak var ringtonePlayerPlayLabel: UILabel!
    
    /// Associated ringtone object to show in this view
    var ringtone : Ringtone!
    
    /// AVAudioPlayer object, used for playing audio
    var audioPlayer : AVAudioPlayer?
    
    /// Timer object used for showing play duration
    var timer : Timer?
    
    // MARK: UIViewController override methods
    /// Called when view will appear. Prepares outlets with values from associated ringtone object
    ///
    /// - Parameter animated: true if view will appear with animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ringtone != nil {
            self.nameLabel.text = ringtone.name
            self.appLabel.text = ringtone.appName
            self.lengthLabel.text = "\(ringtone.totalTime)"
            self.sizeLabel.text = "\(ringtone.size)"
            self.pathLabel.text = ringtone.fileURL.path
            
            self.ringtonePlayerDurationLabel.text = "0 / \(ringtone.totalTime) s"
            
            super.viewWillAppear(animated)
        }
    }
    
    /// Overrides view will disappear, called when view will disappear. Stops playing ringtone.
    ///
    /// - Parameter animated: true if view will disappear with animation
    override func viewWillDisappear(_ animated: Bool) {
        if self.audioPlayer != nil {
            stopPlaying()
            self.audioPlayer = nil
        }
        
        super.viewWillDisappear(animated)
    }
    
    // MARK: Ringtone player methods
    
    func setupPlayer() {
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
            
        } catch {
            Bugfender.error("Error when preparing to play ringtone: \(ringtone) with error: \(error)")
        }
    }
    
    /// Starts playing ringtone if ringtone variable is set
    func playRingtone() {
        guard let player = self.audioPlayer else {
            return
        }
        ringtonePlayerPlayLabel.text = "Stop"
        ringtonePlayerPlayImage.image = UIImage(named: "stop-circle")
        ringtonePlayerDurationLabel.text = "0 / \(Int(round(player.duration)))"
        enableTimer()
        player.play()
    }
    
    /// Stops playing ringtone
    func stopPlaying() {
        guard let player = self.audioPlayer else {
            return
        }
        ringtonePlayerPlayLabel.text = "Play"
        ringtonePlayerPlayImage.image = UIImage(named: "play-circle")
        ringtonePlayerDurationLabel.text = "0 / \(Int(round(player.duration)))"
        stopTimer()
        player.stop()
        self.audioPlayer = nil
        
    }
    
    /// Called when play row is tapped in the associated tableview
    ///
    /// - Parameter sender: UITapGestureRecognizer that initiated this call
    @IBAction func playRowTapped(_ sender: UITapGestureRecognizer) {
        if self.audioPlayer == nil {
            setupPlayer()
        }
        
        guard let player = self.audioPlayer else {
            return
        }
        
        if player.isPlaying {
            stopPlaying()
        } else {
            playRingtone()
        }
        
    }
    
    func enableTimer() {
        guard self.audioPlayer != nil else { return }
        
        timer = Timer(timeInterval: 0.1, target: self, selector: (#selector(self.updateProgress)), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode(rawValue: "NSDefaultRunLoopMode"))
    }
    
    func stopTimer() {
        guard let timer = self.timer else { return }
        
        timer.invalidate()
    }
    
    @objc func updateProgress(){
        guard let player = self.audioPlayer else {
            return
        }
        player.updateMeters() //refresh state
        let currentTime : Int = Int(round(player.currentTime))
        ringtonePlayerDurationLabel.text = "\(currentTime) / \(Int(round(player.duration)))"
    }
    
    //MARK: AVAudioPlayerDelegate methods
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Bugfender.warning("Audio playback error: \(String(describing: error))")
        stopPlaying()
    }
}
