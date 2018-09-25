//
//  HelpTableViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-22.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class HelpTableViewController : UITableViewController {
    
    var helpDataSource = HelpData.getHelpData()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let helpData = helpDataSource[indexPath.row]
        let shown = helpDataSource[indexPath.row].textShown
        helpData.textShown = !shown
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpCell") as! HelpTableViewCell
        
        cell.setValues(helpDataSource[indexPath.row])
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return helpDataSource.count
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 54
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
}
