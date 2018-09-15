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

/// Shows available and installed ringtones
public class RingtoneTableViewController : UITableViewController {
    
    /// Storage for Ringtones
    internal var ringtoneStore : RingtoneStore!

    /// Identifier for Cell used to show a ringtone
    private let cellId = "RingtoneTableCell"
    
    /// Height for each row
    private let rowHeight : CGFloat = 55
    
    /// Userdefaults object
    let defaults = UserDefaults.standard
    
    /// Table filter variable 0=All, 1=Installed, 2=Not installed
    var ringtoneFilter : Int = 0

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
        { (action) -> Void in
            
            self.ringtoneStore.installRingtone(ringtone, completionHandler: { (installedRingtone, success) in
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
    
    func installAllRingtones(withAlert : Bool = true) {
        if withAlert {
            
            let title = "Install all available ringtones"
            let message = "This will install ALL available ringtones. Are you sure you want to continue?"
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
                        HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Installed \(installedTones) ringtones, however \(failedTones) failed"), delay: 1.0)
                    } 
                    
                    strongSelf.tableView.reloadData()
                })
                
            })
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
            
            strongSelf.ringtoneStore.uninstallRingtone(ringtone, completionHandler: { (uninstalledRingtone) in
                inCell.updateInstallStatus()
                HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Uninstalled ringtone"), delay: 0.7)
            })
        })
        ac.addAction(installAction)
        present(ac, animated: true, completion: nil)
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
            self.ringtoneStore.removeRingtone(ringtone, completion: { (deletedRingtone) in
                
                if let index = self.tableView.indexPath(for: inCell) {
                    self.tableView.deleteRows(at: [index], with: .automatic)
                    HUD.flash(.labeledSuccess(title: "Success!", subtitle: "Deleted ringtone"), delay: 0.7)
                }
            })
        })
        ac.addAction(deleteAction)
        present(ac, animated: true, completion: nil)
    }
}


//MARK: UI Actions
extension RingtoneTableViewController {
    
    @IBAction func installAllTapped(_ sender: UIBarButtonItem) {
        
    }
    
    
    @IBAction func uninstallAllTapped(_ sender: UIBarButtonItem) {
        
    }
    
    /// Called when install button is tapped in ’RingtoneTableCell’
    ///
    /// - Parameter sender: Button that was tapped
    @IBAction func installRingtone(_ sender: UIButton) {
        if let indexPath = tableView.indexPathForSelectedRow {
            
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
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            deleteRingtone(inCell: cell)
        }
    }
    
    /// Executes when the user changes the filter to show either "All", "Installed" or "Not installed" Ringtones
    ///
    /// - Parameter sender: UISegmentedControl that triggered this
    @IBAction public func filterChanged(_ sender: UISegmentedControl) {
    }
    
    /// Refresh button was tapped. Rescans apps to find new ringtones
    ///
    /// - Parameter sender: Button that triggered this
    @IBAction public func updateTapped(_ sender: UIBarButtonItem) {
        updateRingtones()
    }
}


//MARK: RingtoneStore callback
extension RingtoneTableViewController {
    func dataFinishedLoading() {
        updateRingtones()
    }
}


//MARK: Notification observers
extension RingtoneTableViewController {
    
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    /// Called from notification observer when app will enter foreground. Updates available ringtones
    @objc public func willEnterForeground() {
        BFLog("did become active, autoinstall = \(Preferences.autoInstall)")
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
        
        // deselect the selected row if any
        NSLog("ViewWillAppear")
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
        super.viewWillAppear(animated)
    }
    
    /// Called whe view will disappear. Deselects a selected row, if any is selected. Also makes sure the buttons in the
    /// selected cell is hidden
    ///
    /// - Parameter animated: true if view will disappear with animation
    override public func viewWillDisappear(_ animated: Bool) {
        // deselect the selected row if any
        let selectedRow: IndexPath? = tableView.indexPathForSelectedRow
        if let selectedRowNotNill = selectedRow {
            print(selectedRowNotNill)
            if let cell = tableView.cellForRow(at: selectedRowNotNill) as? RingtoneTableCell {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.updateButtons(false)
                })
            }
            tableView.deselectRow(at: selectedRowNotNill, animated: true)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
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
            detailViewController.ringtoneStore = self.ringtoneStore
            
        case "showDetailsFromCellButton"?:
            if let indexPath = tableView.indexPathForSelectedRow {
                let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
                let detailViewController = segue.destination as! RingtoneDetailViewController
                detailViewController.ringtone = cell.ringtoneItem
                detailViewController.ringtoneStore = self.ringtoneStore
            }
        case "showSettingsFromBarButton"?:
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.ringtoneStore = self.ringtoneStore
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
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
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
    override public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow, // second tap on already selected cell
            indexPathForSelectedRow == indexPath {
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
    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
            cell.updateButtons(true)
        }, completion: nil)
    }
    /// UITableView delegate method. Row at indexpath was deselected. Hides buttons in cell.
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: Indexpath for cell
    override public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
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
            return rowHeight*1.7
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
            return ringtoneStore.allRingtones.count
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
            let ringtone = ringtoneStore.allRingtones[indexPath.row]
            ringtoneStore.allRingtones.unlockArray()
            cell.ringtoneItem = ringtone
            cell.nameLabel.text = ringtone?.name
            cell.fromAppLabel.text = ringtone?.appName
            cell.lengthLabel.text = String(ringtone?.totalTime ?? 0) + " s"
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
