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

/// Shows available and installed ringtones
class RingtoneTableViewController : UITableViewController {
    
    /// Storage for Ringtones
    fileprivate var ringtoneStore : RingtoneStore!

    /// Identifier for Cell used to show a ringtone
    private let cellId = "RingtoneTableCell"
    
    /// Height for each row
    private let rowHeight : CGFloat = 55
    
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
    
    /// Rescans apps to find new ringtones
    func updateRingtones() {
        
        //        HUD.show(.labeledProgress(title: "Updating", subtitle: "Scanning for new ringtones"))
        
        ringtoneStore.updateRingtones { [weak self] (needsUpdate: Bool)  in
            guard let strongSelf = self else { return }
            
            NSLog("updateringtones callback")
            if (needsUpdate) {
                NSLog("updateringtones callback, got true for needsupdate")
                HUD.allowsInteraction = true
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Updated available ringtones"), delay: 0.5)
                strongSelf.ringtoneStore.allRingtones.lockArray()
                strongSelf.tableView.reloadData()
                strongSelf.ringtoneStore.allRingtones.unlockArray()
            }
        }
    }
    
    func installRingtone(inCell: RingtoneTableCell) {
        guard let ringtone = inCell.ringtoneItem else { return }
        
        let title = "Install \(ringtone.name)"
        let message = "Are you sure you want to add this ringtone to device ringtones?"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let installAction = UIAlertAction(title: "Install", style: .default, handler:
        { [weak self] (action) -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.ringtoneStore.installRingtone(ringtone, completionHandler: { (installedRingtone, success) in
                if (success) {
                    
                    BFLog("Got success in callback from ringtone install")
                    inCell.updateInstallStatus()
                    HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed ringtone"), delay: 0.7)
                } else {
                    
                    BFLog("Got failure in callback from ringtone install")
                    HUD.flash(.labeledError(title: "Error", subtitle: "Error when installing ringtone"), delay: 0.7)
                }
            })
        })
        ac.addAction(installAction)
        present(ac, animated: true, completion: nil)
    }
    
    
    //TODO: Add number of ringtones this action will install in alert
    func installAllRingtones(withAlert : Bool = true) {
        
        if ringtoneStore.notInstalledRingtones.count == 0 {
            HUD.allowsInteraction = true
            HUD.flash(.label("All available ringtones are already installed"), delay: 1.0)
            return
        }
        
        if withAlert {
            
            let title = "Install all available ringtones"
            let message = "This will install \(ringtoneStore.notInstalledRingtones.count) ringtones. Are you sure you want to continue?"
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let installAction = UIAlertAction(title: "Install All", style: .default, handler:
            { [weak self] (action) -> Void in
                guard let strongSelf = self else { return }
                
                HUD.show(.labeledProgress(title: "Installing", subtitle: "Installing all ringtones"))
                
                BFLog("Calling install for all ringtones")
                
                strongSelf.ringtoneStore.installAllRingtones(completionHandler: { (installedTones : Int, failedTones : Int) in
                    
                    if installedTones > 0, failedTones == 0 {
                        HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones"), delay: 1.0)
                    } else if installedTones > 0, failedTones > 0 {
                        HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones, however \(failedTones) failed to install"), delay: 1.0)
                    } else if installedTones == 0 {
                        HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were imported because of an unknown error"), delay: 1.0)
                    } else {
                        HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
                    }
                    
                    strongSelf.tableView.reloadData()
                })
                
            })
            ac.addAction(installAction)
            present(ac, animated: true, completion: nil)
        }
    }
    
    
    func uninstallRingtone(inCell: RingtoneTableCell) {
        guard let ringtone = inCell.ringtoneItem else { return }
        
        let title = "Uninstall \(ringtone.name)"
        let message = "Are you sure you want to uninstall this ringtone?"
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let installAction = UIAlertAction(title: "Uninstall", style: .destructive, handler:
        { [weak self] (action) -> Void in
            guard let strongSelf = self else { return }
            
            strongSelf.ringtoneStore.uninstallRingtone(ringtone, completionHandler: { (success) in
                if success {
                    inCell.updateInstallStatus()
                    HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled ringtone"), delay: 0.7)
                } else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when uninstalling ringtone"), delay: 1.0)
                }
            })
        })
        ac.addAction(installAction)
        present(ac, animated: true, completion: nil)
    }
    
    func uninstallAll(withAlert : Bool = true) {
        if ringtoneStore.installedRingtones.count == 0 {
            HUD.allowsInteraction = true
            HUD.flash(.label("No ringtones are installed"), delay: 1.0)
            return
        }
        
        if withAlert {
            
            let title = "Uninstall all installed ringtones"
            let message = "This will uninstall \(ringtoneStore.installedRingtones.count) ringtones. Are you sure you want to continue?"
            let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let installAction = UIAlertAction(title: "Uninstall All", style: .default, handler:
            { [weak self] (action) -> Void in
                guard let strongSelf = self else { return }
                
                HUD.show(.labeledProgress(title: "Uninstalling", subtitle: "Uninstalling all ringtones"))
                
                BFLog("Calling uninstall for all ringtones")
                
                strongSelf.ringtoneStore.uninstallAllRingtones(completionHandler: { (uninstalledTones : Int, failedTones : Int) in
                    
                    if uninstalledTones > 0, failedTones == 0 {
                        HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled \(uninstalledTones) ringtones"), delay: 1.0)
                    } else if uninstalledTones > 0, failedTones > 0 {
                        HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled \(uninstalledTones) ringtones, however \(failedTones) failed to install"), delay: 1.0)
                    } else if uninstalledTones == 0 {
                        HUD.flash(.labeledError(title: "Error", subtitle: "No ringtones were uninstalled because of an unknown error"), delay: 1.0)
                    } else {
                        HUD.flash(.labeledError(title: "Super Mega Error", subtitle: "Well, this is embarassing. This should not happen"), delay: 2.0)
                    }
                    
                    strongSelf.tableView.reloadData()
                })
                
            })
            ac.addAction(installAction)
            present(ac, animated: true, completion: nil)
        }
    }
    
    
    func deleteRingtone(inCell: RingtoneTableCell) {
        guard let ringtone = inCell.ringtoneItem else { return }
        
        let title = "Delete \(ringtone.name)"
        let message = "Are you sure you want to delete this ringtone from this app? It will also be removed from the devices ringtones if installed. If you do not remove it from the source app it will get imported again at next refresh."
        let ac = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        ac.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler:
        { (action) -> Void in
            self.ringtoneStore.removeRingtone(ringtone, completion: { (success) in
                if success, let index = self.tableView.indexPath(for: inCell) {
       
                    self.tableView.deleteRows(at: [index], with: .automatic)
                    HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted ringtone"), delay: 0.7)
                } else {
                    HUD.flash(.labeledError(title: "Error", subtitle: "Unknown error when deletin ringtone"), delay: 1.0)
                }
            })
        })
        ac.addAction(deleteAction)
        present(ac, animated: true, completion: nil)
    }
}


//MARK: UI Actions
extension RingtoneTableViewController {
    
    @IBAction func playTappedInCell(_ sender: UIButton) {
        if ringtonePlayer == nil {
            ringtonePlayer = RingtonePlayer(inTableView: tableView)
        }
        
        ringtonePlayer?.togglePlayForSelectedRingtone()
        
    }
    
    @IBAction func installAllTapped(_ sender: UIBarButtonItem) {
        ringtonePlayer?.stopPlaying()
        installAllRingtones()
    }
    
    
    @IBAction func uninstallAllTapped(_ sender: UIBarButtonItem) {
        ringtonePlayer?.stopPlaying()
        uninstallAll()
    }
    
    /// Called when install button is tapped in ’RingtoneTableCell’
    ///
    /// - Parameter sender: Button that was tapped
    @IBAction func installRingtone(_ sender: UIButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            
            ringtonePlayer?.stopPlaying()
            
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            guard let ringtone = cell.ringtoneItem else { return }
            
            if !ringtone.installed { // is not installed
                
                installRingtone(inCell: cell)
            } else { // is installed
                
                uninstallRingtone(inCell: cell)
            }
        }
    }
    
    /// Called when trash button is tapped in ’RingtoneTableCell’. Deletes ringtone.
    ///
    /// - Parameter sender: Button that was tapped
    @IBAction func deleteRingtone(_ sender: UIButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            ringtonePlayer?.stopPlaying()
            
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            deleteRingtone(inCell: cell)
        }
    }
    
    /// Executes when the user changes the filter to show either "All", "Installed" or "Not installed" Ringtones
    ///
    /// - Parameter sender: UISegmentedControl that triggered this
    @IBAction public func filterChanged(_ sender: UISegmentedControl) {
        ringtonePlayer?.stopPlaying()
        
        ringtoneFilter = sender.selectedSegmentIndex
        ringtoneStore.allRingtones.lockArray()
        tableView.reloadData()
        ringtoneStore.allRingtones.unlockArray()
    }
    
    /// Refresh button was tapped. Rescans apps to find new ringtones
    ///
    /// - Parameter sender: Button that triggered this
    @IBAction public func updateTapped(_ sender: UIBarButtonItem) {
        updateRingtones()
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
    @objc public func willEnterForeground() {
        BFLog("did become active, autoinstall = \(Preferences.autoInstall)")
        updateRingtones()
    }
    
    @objc func dataFinishedLoading(notification: NSNotification) {
        tableView.reloadData()
        updateRingtones()
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
            
            deleteRingtone(inCell: cell)
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


