//
//  RingtoneTableCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
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

/// UITableCell subclass for ringtones, used in ’RingtoneTableViewController’
final class RingtoneTableCell: UITableViewCell {
    /// Outlet for name label UILabel
    @IBOutlet weak var nameLabel: UILabel!
    
    /// Outlet for label showing which app ringtone was imported from
    @IBOutlet weak var fromAppLabel: UILabel!
    
    @IBOutlet weak var cellMenuButton: RingtoneCellButton!
    
    
    /// Outlet for UIButton with play/pause action
    @IBOutlet weak var playButton: UIButton!
    
    /// Outlet for "more info", segues to ’RingtoneDetailViewController’ on tap
    @IBOutlet weak var infoButton: UIButton!
    
    /// Associated ringtone object
    var ringtoneItem : Ringtone? = nil

}

//MARK: Cell UIView update actions
extension RingtoneTableCell {
    /// Updates state of buttons (hidden/shown)
    ///
    /// - Parameter state: Bool, true for shown and false for hidden
    public func updateButtons(_ state: Bool) {
        if state == true {

//            cellMenuButton.frame.size = CGSize(width: 44, height: 44)
            if !playButton.isEnabled {
                cellMenuButton.transform = CGAffineTransform(scaleX: 44/30, y: 44/30)
            }
            
            playButton.alpha = 0.7
            playButton.isEnabled = true
            
            infoButton.alpha = 0.7
            infoButton.isEnabled = true
            
        } else {

//            cellMenuButton.frame.size = CGSize(width: 30, height: 30)
            if playButton.isEnabled {
                cellMenuButton.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
            playButton.alpha = 0.0
            playButton.isEnabled = false
            
            infoButton.alpha = 0.0
            infoButton.isEnabled = false
            
        }
    }
    
    /// Updates UIImage for install button to show if button action is install or uninstall. Also updates installed label
    public func updateInstallStatus() {
        if !(ringtoneItem?.installed)! { // not installed
            nameLabel.textColor = ColorPalette.ringtoneNotInstalledColor
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } else { // installed
            nameLabel.textColor = ColorPalette.ringtoneInstalledColor
            
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
}

//MARK: UITableViewCell override methods
extension RingtoneTableCell {
    /// UITableViewCell function which prepares cell for reuse
    override public func prepareForReuse() {
        nameLabel.text = ""
        fromAppLabel.text = ""
        updateButtons(false)
        ringtoneItem = nil
    }

    
}
