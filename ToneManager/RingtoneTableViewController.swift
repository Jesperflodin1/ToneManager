//
//  RingtoneTableViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class RingtoneTableViewController : UITableViewController {
    
    var ringtoneStore : RingtoneStore!
    
//    private let headerId = "ringtonesHeaderId"
    private let cellId = "JFTMRingtoneCell"
    private let rowHeight : CGFloat = 55
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        settingsButton.setFAIcon(icon: .FACogs, iconSize: 30)
//        view.backgroundColor = UIColor.lightGray
        
//        self.navigationController?.navigationBar.tintColor = UIColor.green
//        self.navigationItem.titleView?.backgroundColor = UIColor.green
        
//        tableView.backgroundColor = UIColor.lightGray
//        tableView.register(RingtoneTableViewHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
//        tableView.register(RingtoneTableCell.self, forCellReuseIdentifier: cellId)
    }
    
    
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 80
//    }
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as! RingtoneTableViewHeader
//        header.textLabel?.text = "TEST"
//        header.detailTextLabel?.text = "test"
//        header.contentView.backgroundColor = UIColor.white
//        return header
//    }
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let indexPathForSelectedRow = tableView.indexPathForSelectedRow,
            indexPathForSelectedRow == indexPath {
            tableView.deselectRow(at: indexPath, animated: true)
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            return nil
        }
        return indexPath
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.tableView.indexPathForSelectedRow?.row == indexPath.row {
            return rowHeight*2
        } else {
            return rowHeight
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ringtoneStore.allRingtones.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RingtoneTableCell
        
        let ringtone = ringtoneStore.allRingtones[indexPath.row]
        
        cell.nameLabel.text = ringtone.name
        cell.fromAppLabel.text = ringtone.bundleID
        
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let ringtone = ringtoneStore.allRingtones[indexPath.row]
            
            ringtoneStore.removeRingtone(ringtone)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
}
