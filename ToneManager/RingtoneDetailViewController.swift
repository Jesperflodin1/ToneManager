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
import PKHUD

/// View controller that shows details page for ringtone
final class RingtoneDetailViewController : UITableViewController {
    
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
    
    
    @IBOutlet weak var installCellLabel: UILabel!
    @IBOutlet weak var deleteCellLabel: UILabel!
    
    /// Associated ringtone object to show in this view
    var ringtone : Ringtone!
    
    var ringtoneStore : RingtoneStore!
    
    /// AVAudioPlayer object, used for playing audio
    var audioPlayer : AVAudioPlayer?
    
    /// Timer object used for showing play duration
    var timer : Timer?
    
    required init?(coder aDecoder: NSCoder) {
        self.ringtoneStore = RingtoneStore.sharedInstance
        super.init(coder: aDecoder)
    }
}

//MARK: UITableViewCell updating methods
extension RingtoneDetailViewController {
    func updateInstallStatus() {
        
        if ringtone.installed {
            installCellLabel.text = "Uninstall Ringtone"
            installCellLabel.textColor = ColorPalette.destructiveColor
            deleteCellLabel.text = "Delete and uninstall ringtone"
        } else {
            installCellLabel.text = "Install Ringtone"
            installCellLabel.textColor = ColorPalette.cellActionColor
            deleteCellLabel.text = "Delete Ringtone"
        }
    }
}

//MARK: UI Tap Actions
extension RingtoneDetailViewController {
    
    @IBAction func installRowTapped(_ sender: UITapGestureRecognizer) {
        if !ringtone.installed { // is not installed
            
            installRingtone(ringtone: ringtone)
            
        } else { // is installed
            
            uninstallRingtone(ringtone: ringtone)
        }
    }
    
    
    @IBAction func deleteRowTapped(_ sender: UITapGestureRecognizer) {
        deleteRingtone(ringtone: self.ringtone)
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
    
    
}

//MARK: Install/uninstall ringtone methods
extension RingtoneDetailViewController {
    func installRingtone(ringtone: Ringtone) {
        
        let title = "Install \(ringtone.name)"
        let message = "Are you sure you want to add this ringtone to device ringtones?"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let installAction = UIAlertAction(title: "Install", style: .default, handler:
        { (action) -> Void in
            
            self.ringtoneStore.installRingtone(ringtone, completionHandler: { [weak self] (installedRingtone, success) in
                if (success) {
                    guard let strongSelf = self else { return }
                    
                    BFLog("Got success in callback from ringtone install")
                    strongSelf.updateInstallStatus()
                    HUD.allowsInteraction = true
                    HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed ringtone"), delay: 0.7)
                    strongSelf.ringtoneStore.writeToPlist()
                } else {
                    
                    BFLog("Got failure in callback from ringtone install")
                    HUD.allowsInteraction = true
                    HUD.flash(.labeledError(title: "Error", subtitle: "Error when installing ringtone"), delay: 0.7)
                }
            })
        })
        ac.addAction(installAction)
        present(ac, animated: true, completion: nil)
    }
    
    
    func uninstallRingtone(ringtone: Ringtone) {
        
        let title = "Uninstall \(ringtone.name)"
        let message = "Are you sure you want to uninstall this ringtone?"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let installAction = UIAlertAction(title: "Uninstall", style: .destructive, handler:
        { [weak self] (action) -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.ringtoneStore.uninstallRingtone(ringtone, completionHandler: { (uninstalledRingtone) in
                strongSelf.updateInstallStatus()
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled ringtone"), delay: 0.7)
            })
        })
        ac.addAction(installAction)
        present(ac, animated: true, completion: nil)
    }
    
    
    func deleteRingtone(ringtone: Ringtone) {
        
        let title = "Delete \(ringtone.name)"
        let message = "Are you sure you want to delete this ringtone from this app? It will also be removed from the devices ringtones if installed. If you do not remove it from the source app it will get imported again at next refresh."
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler:
        { [weak self] (action) -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.ringtoneStore.removeRingtone(ringtone, completion: { (deletedRingtone) in
                _ = strongSelf.navigationController?.popViewController(animated: true)
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted ringtone"), delay: 0.7)
                
            })
        })
        ac.addAction(deleteAction)
        present(ac, animated: true, completion: nil)
    }
}

//MARK: AVAudioPlayer methods
extension RingtoneDetailViewController {
    
    private func humanReadableDuration(_ duration: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.roundingMode = NumberFormatter.RoundingMode.halfUp
        formatter.maximumFractionDigits = 1
        
        guard let durationString = formatter.string(from: NSNumber(value: duration)) else {
            return "nil"
        }
        return durationString
    }
    
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
        ringtonePlayerDurationLabel.text = "0.0 / \(humanReadableDuration(player.duration)) s"
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
        ringtonePlayerDurationLabel.text = "0.0 / \(humanReadableDuration(player.duration)) s"
        stopTimer()
        player.stop()
        self.audioPlayer = nil
        
    }
    
    
    
    func enableTimer() {
        guard self.audioPlayer != nil else { return }
        
        timer = Timer(timeInterval: 0.05, target: self, selector: (#selector(self.updateProgress)), userInfo: nil, repeats: true)
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
  
        ringtonePlayerDurationLabel.text = "\(humanReadableDuration(player.currentTime)) / \(humanReadableDuration(player.duration))"
    }
}

//MARK: AVAudioPlayerDelegate methods
extension RingtoneDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaying()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Bugfender.warning("Audio playback error: \(String(describing: error))")
        stopPlaying()
    }
}

//MARK: UIViewController override methods
extension RingtoneDetailViewController {
    
    /// Called when view will appear. Prepares outlets with values from associated ringtone object
    ///
    /// - Parameter animated: true if view will appear with animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if ringtone != nil {
            self.nameLabel.text = ringtone.name
            self.appLabel.text = ringtone.appName
            self.lengthLabel.text = "\(humanReadableDuration(ringtone.rawDuration)) s"
            self.sizeLabel.text = "\(ringtone.humanReadableSize())"
            self.pathLabel.text = ringtone.fileURL.path
            
            self.ringtonePlayerDurationLabel.text = "0.0 / \(humanReadableDuration(ringtone.rawDuration)) s"
            
            updateInstallStatus()
            
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
}
