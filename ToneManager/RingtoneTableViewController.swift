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

class RingtoneTableViewController : UITableViewController {
    
    var ringtoneStore : RingtoneStore!
    
//    private let headerId = "ringtonesHeaderId"
    private let cellId = "RingtoneTableCell"
    private let rowHeight : CGFloat = 55
    
    
    @IBAction func filterChanged(_ sender: UISegmentedControl) {
    }
    
    @IBAction func updateTapped(_ sender: UIBarButtonItem) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        ringtoneStore.allRingtones.lockArray()
        tableView.reloadData()
        ringtoneStore.allRingtones.unlockArray()
        
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
    override func viewWillDisappear(_ animated: Bool) {
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

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
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
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
        UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
            cell.updateButtons(true)
        }, completion: nil)
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
        UIView.animate(withDuration: 0.2, animations: {
            cell.updateButtons(false)
        })
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tableView.indexPathForSelectedRow?.row == indexPath.row {
            return rowHeight*1.7
        } else {
            return rowHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ringtoneStore.allRingtones.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RingtoneTableCell
        
        ringtoneStore.allRingtones.lockArray()
        let ringtone = ringtoneStore.allRingtones[indexPath.row]
        ringtoneStore.allRingtones.unlockArray()
        cell.ringtoneItem = ringtone
        cell.nameLabel.text = ringtone?.name
        cell.fromAppLabel.text = ringtone?.appName
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let cell = tableView.cellForRow(at: indexPath) as! RingtoneTableCell
            
            ringtoneStore.allRingtones.remove(where: { $0 == cell.ringtoneItem }, completion: { (deletedRingtone) in
                if let index = tableView.indexPath(for: cell) {
                    tableView.deleteRows(at: [index], with: .automatic)
                }
            })
        }
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
