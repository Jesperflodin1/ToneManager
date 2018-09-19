//
//  RingtoneTableViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK
import PKHUD
import AVFoundation
import XLActionController

/// Shows available and installed ringtones
final class RingtoneTableViewController : UITableViewController {
    
    /// Storage for Ringtones
    fileprivate var ringtoneStore : RingtoneStore!
    
    /// Identifier for Cell used to show a ringtone
    private let cellId = "RingtoneTableCell"
    
    /// Height for each row
    private let rowHeight : CGFloat = 60
    
    /// Userdefaults object
    let defaults = UserDefaults.standard
    
    /// Table filter variable 0=All, 1=Installed, 2=Not installed
    var ringtoneFilter : Int = 0
    
    var ringtonePlayer : RingtonePlayer?
    
    public required init?(coder aDecoder: NSCoder) {
        ringtoneStore = RingtoneStore.sharedInstance
        super.init(coder: aDecoder)
    }
    
}


//MARK: RingtoneStore methods
extension RingtoneTableViewController {
    
    func updateAvailableRingtones() {
        RingtoneManager.updateRingtones { [weak self] in
            guard let strongSelf = self else { return }
            
            strongSelf.ringtoneStore.allRingtones.lockArray()
            strongSelf.tableView.reloadData()
            strongSelf.ringtoneStore.allRingtones.unlockArray()
        }
    }
}


//MARK: UI Actions
extension RingtoneTableViewController {
    
    @IBAction func cellMenuTapped(_ sender: RingtoneCellButton) {
        let row = sender.tag
        guard let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? RingtoneTableCell else {
            Bugfender.error("Error! Failed to get cell on menu tap")
            return
        }
        guard let ringtone = cell.ringtoneItem else { return }
        
        let actionController = ActionSheetController()
        
        ringtonePlayer?.stopPlaying()
        
        if ringtone.installed {
            actionController.addAction(Action(ActionData(title: "Uninstall", image: ColorPalette.ringtoneCellMenuUninstall!), style: .default, handler: { action in
                
                RingtoneManager.uninstallRingtone(inCell: cell) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.ringtoneStore.allRingtones.lockArray()
                    strongSelf.tableView.reloadData()
                    strongSelf.ringtoneStore.allRingtones.unlockArray()
                }
                
            }))
        } else {
            actionController.addAction(Action(ActionData(title: "Install", image: ColorPalette.ringtoneCellMenuInstall!), style: .default, handler: { action in
                
                RingtoneManager.installRingtone(inCell: cell) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.ringtoneStore.allRingtones.lockArray()
                    strongSelf.tableView.reloadData()
                    strongSelf.ringtoneStore.allRingtones.unlockArray()
                }
                
            }))
        }
        actionController.addAction(Action(ActionData(title: "Show details", image: ColorPalette.ringtoneCellMenuInfo!), style: .default, handler: { [weak self] action in
            guard let strongSelf = self else { return }
            
            strongSelf.performSegue(withIdentifier: "showDetailsFromCellLabel", sender: cell)
            
        }))
        actionController.addAction(Action(ActionData(title: "Delete", image: ColorPalette.ringtoneCellMenuDelete!), style: .destructive, handler: { action in
            
            RingtoneManager.deleteRingtone(inCell: cell) { [weak self] in
                guard let strongSelf = self else { return }
                if let index = strongSelf.tableView.indexPath(for: cell) {
                    
                    strongSelf.tableView.deleteRows(at: [index], with: .automatic)

                    strongSelf.ringtoneStore.allRingtones.lockArray()
                    strongSelf.tableView.reloadData()
                    strongSelf.ringtoneStore.allRingtones.unlockArray()
                }
            }
            
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: ColorPalette.ringtoneCellMenuCancel!), style: .cancel, handler: nil))
        
        present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func playTappedInCell(_ sender: UIButton) {
        if ringtonePlayer == nil {
            ringtonePlayer = RingtonePlayer(inTableView: tableView)
        }
        
        ringtonePlayer?.togglePlayForSelectedRingtone()
        
    }
    
    @IBAction func installAllTapped(_ sender: UIBarButtonItem) {
        ringtonePlayer?.stopPlaying()
        RingtoneManager.installAllRingtones(withAlert: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.ringtoneStore.allRingtones.lockArray()
            strongSelf.tableView.reloadData()
            strongSelf.ringtoneStore.allRingtones.unlockArray()
        }
    }
    
    
    @IBAction func uninstallAllTapped(_ sender: UIBarButtonItem) {
        ringtonePlayer?.stopPlaying()
        RingtoneManager.uninstallAll(withAlert: true) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.ringtoneStore.allRingtones.lockArray()
            strongSelf.tableView.reloadData()
            strongSelf.ringtoneStore.allRingtones.unlockArray()
        }
    }
    
    /// Executes when the user changes the filter to show either "All", "Installed" or "Not installed" Ringtones
    ///
    /// - Parameter sender: UISegmentedControl that triggered this
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
        ringtonePlayer?.stopPlaying()
        
        ringtoneFilter = sender.selectedSegmentIndex
        ringtoneStore.allRingtones.lockArray()
        tableView.reloadData()
        ringtoneStore.allRingtones.unlockArray()
    }
    
    /// Refresh button was tapped. Rescans apps to find new ringtones
    ///
    /// - Parameter sender: Button that triggered this
    @IBAction func updateTapped(_ sender: UIBarButtonItem) {
        updateAvailableRingtones()
    }
    
    private func deselectCurrentRow() {
        let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            
            if let cell = tableView.cellForRow(at: selectedRowNotNill) as? RingtoneTableCell {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.updateButtons(false)
                })
            }
            tableView.deselectRow(at: selectedRowNotNill, animated: true)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
}

//MARK: Notification observers
extension RingtoneTableViewController {
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(self.dataFinishedLoading(notification:)), name: .ringtoneStoreDidFinishLoading, object: nil)
    }
    
    /// Called from notification observer when app will enter foreground. Updates available ringtones
    @objc func willEnterForeground() {
        BFLog("did become active, autoinstall = \(Preferences.autoInstall)")
        updateAvailableRingtones()
    }
    
    @objc func dataFinishedLoading(notification: NSNotification) {
        tableView.reloadData()
        updateAvailableRingtones()
    }
}




//MARK: UIViewController method overrides
extension RingtoneTableViewController {
    
    /// Called when view has finished loading
    override public func viewDidLoad() {
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        registerObservers()
        
        super.viewDidLoad()
    }
    
    /// Called when view will appear
    ///
    /// - Parameter animated: true if view appears with animation
    override public func viewWillAppear(_ animated: Bool) {
        if ringtoneStore.finishedLoading {
            ringtoneStore.allRingtones.lockArray()
            tableView.reloadData()
            ringtoneStore.allRingtones.unlockArray()
        }
        
        deselectCurrentRow()
        super.viewWillAppear(animated)
    }
    
    /// Called whe view will disappear. Deselects a selected row, if any is selected. Also makes sure the buttons in the
    /// selected cell is hidden
    ///
    /// - Parameter animated: true if view will disappear with animation
    override public func viewWillDisappear(_ animated: Bool) {
        ringtonePlayer?.stopPlaying()
        
        deselectCurrentRow()
        super.viewWillDisappear(animated)
    }
}

//MARK: Segues handling
extension RingtoneTableViewController {
    /// Called when a segue is triggered
    ///
    /// - Parameters:
    ///   - segue: segue that was triggered. Has a unique identifier.
    ///   - sender: sender that initiated the segue
    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showDetailsFromCellLabel"?:
            let cell = sender as! RingtoneTableCell
            let detailViewController = segue.destination as! RingtoneDetailViewController
            detailViewController.ringtone = cell.ringtoneItem
            
        case "showDetailsFromCellButton"?:
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
                let detailViewController = segue.destination as! RingtoneDetailViewController
                detailViewController.ringtone = cell.ringtoneItem
            }
        default: break
        }
    }
}


//MARK: UITableView Delegate methods
extension RingtoneTableViewController {
    
    /// UITableView delegate method. Called when a ringtone should be removed
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - editingStyle: Style for editing
    ///   - indexPath: Indexpath for cell
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            RingtoneManager.deleteRingtone(inCell: cell) {
                if let index = self.tableView.indexPath(for: cell) {
                    self.tableView.deleteRows(at: [index], with: .automatic)
                }
            }
        }
    }
    /// UITableView delegate method. If a row already is selected, it will deselect it.
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: IndexPath for tapped row
    /// - Returns: IndexPath
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow, // second tap on already selected cell
            indexPathForSelectedRow == indexPath {
            
            ringtonePlayer?.stopPlaying()
            
            tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            if let cell = tableView.cellForRow(at: indexPath) as? RingtoneTableCell {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.updateButtons(false)
                })
            }
            return nil
        }
        return indexPath
    }
    /// UITableView delegate method. Selects row that was tapped and unhides buttons available for this cell
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: IndexPath for selected row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
            cell.updateButtons(true)
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        ringtonePlayer?.stopPlaying()
        return indexPath
    }
    
    /// UITableView delegate method. Row at indexpath was deselected. Hides buttons in cell.
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: Indexpath for cell
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? RingtoneTableCell {
            UIView.animate(withDuration: 0.2, animations: {
                cell.updateButtons(false)
            })
        }
    }
}

//MARK: UITableView DataSource methods
extension RingtoneTableViewController {
    
    /// UITableView Datasource method. Returns height depending on if the cell is selected or not
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: IndexPath for cell
    /// - Returns: Row height
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView.indexPathForSelectedRow?.row == indexPath.row {
            return rowHeight*2.0
        } else {
            return rowHeight
        }
    }
    
    /// UITableView datasource method.
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - section: Current section
    /// - Returns: Returns number of rows in this section (usually number of ringtones)
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if ringtoneStore.finishedLoading {
            switch ringtoneFilter {
            case 0:
                return ringtoneStore.allRingtones.count
            case 1:
                return ringtoneStore.installedRingtones.count
            case 2:
                return ringtoneStore.notInstalledRingtones.count
            default:
                return 0
            }
        } else { return 0 }
    }
    
    /// UITableView Datasource method
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: Indexpath for current cell
    /// - Returns: UITableViewCell of subclass RingtoneTableCell
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RingtoneTableCell
        
        if ringtoneStore.finishedLoading {
            ringtoneStore.allRingtones.lockArray()
            
            let ringtone : Ringtone?
            switch ringtoneFilter {
            case 0:
                ringtone = ringtoneStore.allRingtones[indexPath.row]
            case 1:
                ringtone = ringtoneStore.installedRingtones[indexPath.row]
            case 2:
                ringtone = ringtoneStore.notInstalledRingtones[indexPath.row]
            default:
                ringtoneStore.allRingtones.unlockArray()
                return cell
            }
            ringtoneStore.allRingtones.unlockArray()
            cell.ringtoneItem = ringtone
            cell.nameLabel.text = ringtone?.name
            cell.fromAppLabel.text = ringtone?.appName
            cell.cellMenuButton.addedTouchArea = 10
            cell.cellMenuButton.tag = indexPath.row
            
            cell.updateInstallStatus()
            
            let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
            if let selectedRowNotNill = selectedRow {
                if selectedRowNotNill == indexPath {
                    // current row is selected
                    cell.updateButtons(true)
                }
            }
        }
        
        return cell
    }
}


