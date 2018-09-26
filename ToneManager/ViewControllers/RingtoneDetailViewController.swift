//
//  RingtoneDetailViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-08.
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

import UIKit
import AVFoundation
import XLActionController
import PopupDialog
import BugfenderSDK
import PKHUD
import ContactsUI

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
    
    /// AVAudioPlayer object, used for playing audio
    var audioPlayer : AVAudioPlayer?
    
    /// Timer object used for showing play duration
    var timer : Timer?
    
    var contactPicker : CNContactPickerViewController? = nil
    var ringtoneAssigner : RingtoneAssigner? = nil
    
    @IBAction func editTapped(_ sender: UIBarButtonItem) {
        showNameChangePopup()
    }
    @IBAction func nameCellTapped(_ sender: UITapGestureRecognizer) {
        showNameChangePopup()
    }
    func showNameChangePopup() {
        let textVC = PopupTextInputViewController(nibName: "PopupTextInputViewController", bundle: nil)
        
        
        let popup = PopupDialog(viewController: textVC,
                                buttonAlignment: .horizontal,
                                transitionStyle: .bounceDown,
                                tapGestureDismissal: true,
                                panGestureDismissal: false)
        let buttonOne = CancelButton(title: "CANCEL", height: 60, action: nil)
        
        // Create second button
        let buttonTwo = DefaultButton(title: "CHANGE", height: 60) {
            guard let newName = textVC.nameTextField.text else { return }
            self.ringtone.changeName(newName, ignoreInstalledStatus: false)
        }
        
        // Add buttons to dialog
        popup.addButtons([buttonOne, buttonTwo])
        
        let vc = popup.viewController as! PopupTextInputViewController
        vc.nameTextField.text = ringtone.name
        
        // Present dialog
        present(popup, animated: true, completion: nil)
    }
    @IBAction func openSourceAppTapped(_ sender: UITapGestureRecognizer) {
        stopPlaying()
        if !LSApplicationWorkspaceHandler.openApplication(withBundleID: ringtone.bundleID) {
            Bugfender.error("Failed to open app with LSApplicationWorkspace")
            HUD.flash(.labeledError(title: "Error", subtitle: "Failed to open app, is it installed?"), delay: 1.0)
        }
    }
    @IBAction func assignDefaultTapped(_ sender: UITapGestureRecognizer) {
        stopPlaying()
        let actionController = ActionSheetController()
        
        actionController.addAction(Action(ActionData(title: "Assign as default ringtone", image: ColorPalette.actionSheetMenuMobile!), style: .default, handler: { [weak self] action in
            
            guard let strongSelf = self else { return }
            
            guard let assigner = RingtoneAssigner(ringtone: strongSelf.ringtone) else { return }
            assigner.assignDefaultRingtone()
            
            HUD.allowsInteraction = true
            HUD.flash(.label("Set ringtone as default ringtone"), delay: 1.0)
            
            
        }))
        actionController.addAction(Action(ActionData(title: "Assign as default message tone", image: ColorPalette.actionSheetMenuMessage!), style: .default, handler: { [weak self] action in
            
            guard let strongSelf = self else { return }
            
            guard let assigner = RingtoneAssigner(ringtone: strongSelf.ringtone) else { return }
            assigner.assignDefaultTextTone()
            
            HUD.allowsInteraction = true
            HUD.flash(.label("Set ringtone as default ringtone"), delay: 1.0)
            
            
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: ColorPalette.actionSheetMenuCancel!), style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
        
    }
    @IBAction func assignToContactTapped(_ sender: UITapGestureRecognizer) {
        stopPlaying()
        
        guard let assigner = RingtoneAssigner(ringtone: ringtone) else { return }
        
        ringtoneAssigner = assigner
        openContactPicker()
    }
    
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.storeDidReload(notification:)), name: .ringtoneStoreDidReload, object: nil)
    }
    
    @objc func storeDidReload(notification: NSNotification) {
        BFLog("store did reload in detailview")
        if ringtone != nil {
            self.nameLabel.text = ringtone.name
            self.appLabel.text = ringtone.appName
            self.lengthLabel.text = "\(humanReadableDuration(ringtone.rawDuration)) s"
            self.sizeLabel.text = "\(ringtone.humanReadableSize())"
            
            self.ringtonePlayerDurationLabel.text = "0.0 / \(humanReadableDuration(ringtone.rawDuration)) s"
            
            updateInstallStatus()
            
        }
    }
}

extension RingtoneDetailViewController : CNContactPickerDelegate {
    
    func openContactPicker() {
        contactPicker = CNContactPickerViewController()
        contactPicker!.delegate = self
        
        present(contactPicker!, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        BFLog("contactpicker didselect")
        NSLog("Contactpicker didselect")
        
        let actionController = ActionSheetController()
        
        actionController.addAction(Action(ActionData(title: "Set as default ringtone for contact", image: ColorPalette.actionSheetMenuMobile!), style: .default, handler: { [weak self] action in
            
            guard let strongSelf = self else { return }
            guard let assigner = strongSelf.ringtoneAssigner else { return }
            
            assigner.assignDefaultRingtone(forContact: contact)
            
            strongSelf.contactPicker = nil
            strongSelf.ringtoneAssigner = nil
            
        }))
        actionController.addAction(Action(ActionData(title: "Set as default text tone for contact", image: ColorPalette.actionSheetMenuMessage!), style: .default, handler: { [weak self] action in
            
            guard let strongSelf = self else { return }
            guard let assigner = strongSelf.ringtoneAssigner else { return }
            
            assigner.assignDefaultTextTone(forContact: contact)
            
            strongSelf.contactPicker = nil
            strongSelf.ringtoneAssigner = nil
            
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: ColorPalette.actionSheetMenuCancel!), style: .cancel, handler: nil))
        
        picker.dismiss(animated: true) {
            self.present(actionController, animated: true, completion: nil)
        }
        
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        BFLog("contactpicker didcancel")
        NSLog("Contactpicker didcancel")
        picker.dismiss(animated: true, completion: nil)
        
        contactPicker = nil
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
        stopPlaying()
        if !ringtone.installed { // is not installed
            
            installRingtone(ringtone: ringtone)
            
        } else { // is installed
            
            uninstallRingtone(ringtone: ringtone)
        }
    }
    
    
    @IBAction func deleteRowTapped(_ sender: UITapGestureRecognizer) {
        stopPlaying()
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
        
        let actionController = ActionSheetController()
        actionController.addAction(Action(ActionData(title: "Install", image: ColorPalette.actionSheetMenuInstall!), style: .default, handler: { action in
            
            RingtoneManager.installRingtone(ringtoneObject: ringtone) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.updateInstallStatus()
            }
            
        }))
        
        actionController.addAction(Action(ActionData(title: "Cancel", image: ColorPalette.actionSheetMenuCancel!), style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    
    func uninstallRingtone(ringtone: Ringtone) {
        
        let actionController = ActionSheetController()
        actionController.addAction(Action(ActionData(title: "Uninstall", image: ColorPalette.actionSheetMenuUninstall!), style: .destructive, handler: { action in
            
            RingtoneManager.uninstallRingtone(ringtoneObject: ringtone) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.updateInstallStatus()
            }
            
        }))
        
        actionController.addAction(Action(ActionData(title: "Cancel", image: ColorPalette.actionSheetMenuCancel!), style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    
    func deleteRingtone(ringtone: Ringtone) {
        let title = "Really delete this ringtone?"
        let message = "Are you sure you want to delete this ringtone? It will also be uninstalled if installed on the device. If you do not remove it from the source app it will get imported again at next reload."
        let popup = PopupDialog(title: title, message: message, image: ColorPalette.alertBackground)
        let buttonTwo = CancelButton(title: "Cancel", action: nil)
        let buttonOne = DestructiveButton(title: "Delete") { [weak self] in
            guard let strongSelf = self else { return }
            
            RingtoneManager.deleteRingtone(ringtoneObject: ringtone, onSuccess: {
                _ = strongSelf.navigationController?.popViewController(animated: true)
            })
            
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        
        present(popup, animated: true, completion: nil)
 
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
            Bugfender.error("Error when preparing to play ringtone: \(ringtone.name) with error: \(error)")
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
        if let realError = error {
            Bugfender.warning("Audio playback error: \(realError as NSError)")
        }
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
            
            self.ringtonePlayerDurationLabel.text = "0.0 / \(humanReadableDuration(ringtone.rawDuration)) s"
            
            updateInstallStatus()
            registerObservers()
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
