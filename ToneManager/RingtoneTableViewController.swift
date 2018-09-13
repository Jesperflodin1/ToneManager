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
    
    var autoInstall : Bool {
        get {
            return defaults.bool(forKey: "AutoInstall")
        }
        set {
            defaults.set(newValue, forKey: "AutoInstall")
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
    
    /// Rescans apps to find new ringtones
    public func updateRingtones() {
        HUD.show(.labeledProgress(title: "Updating", subtitle: "Scanning for new ringtones"))
        
        ringtoneStore.updateRingtones { [weak self] (needsUpdate: Bool)  in
            guard let strongSelf = self else { return }
            HUD.flash(.success, delay: 1.0)
            if (needsUpdate) {
                strongSelf.ringtoneStore.allRingtones.lockArray()
                strongSelf.tableView.reloadData()
                strongSelf.ringtoneStore.allRingtones.unlockArray()
            }
        }
    }
    
    override public func viewDidLoad() {
        self.ringtoneStore = RingtoneStore()
        updateRingtones()
        ringtoneStore.tableView = self.tableView
        tableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector:#selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector:#selector(willEnterBackground), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(willEnterBackground), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
    }
    
    @objc public func willEnterForeground() {
        BFLog("did become active, autoinstall = \(autoInstall)")
        updateRingtones()
    }
    @objc public func willEnterBackground() {
        ringtoneStore.writeToPlist()
    }
    
    /// Called when view will appear
    ///
    /// - Parameter animated: true if view appears with animation
    override public func viewWillAppear(_ animated: Bool) {
//        ringtoneStore.allRingtones.lockArray()
//        tableView.reloadData()
//        ringtoneStore.allRingtones.unlockArray()
        
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
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            UIView.animate(withDuration: 0.2, animations: {
                cell.updateButtons(false)
            })
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
        let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
        UIView.animate(withDuration: 0.2, animations: {
            cell.updateButtons(false)
        })
    }
    
    /// UITableView Datasource method. Returns height depending on if the cell is selected or not
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: IndexPath for cell
    /// - Returns: Row height
    override public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tableView.indexPathForSelectedRow?.row == indexPath.row {
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
        return ringtoneStore.allRingtones.count
    }
    
    /// UITableView Datasource method
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - indexPath: Indexpath for current cell
    /// - Returns: UITableViewCell of subclass RingtoneTableCell
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RingtoneTableCell
        
        ringtoneStore.allRingtones.lockArray()
        let ringtone = ringtoneStore.allRingtones[indexPath.row]
        ringtoneStore.allRingtones.unlockArray()
        cell.ringtoneItem = ringtone
        cell.nameLabel.text = ringtone?.name
        cell.fromAppLabel.text = ringtone?.appName
        
        return cell
    }
    
    /// UITableView delegate method. Called when a ringtone should be removed
    ///
    /// - Parameters:
    ///   - tableView: current UITableView
    ///   - editingStyle: Style for editing
    ///   - indexPath: Indexpath for cell
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            ringtoneStore.allRingtones.remove(where: { $0 == cell.ringtoneItem }, completion: { (deletedRingtone) in
                if let index = tableView.indexPath(for: cell) {
                    tableView.deleteRows(at: [index], with: .automatic)
                }
            })
        }
    }
    
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
