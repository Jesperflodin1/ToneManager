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
    
    private let headerId = "ringtonesHeaderId"
    private let cellId = "ringtonesCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.lightGray
        
        tableView.backgroundColor = UIColor.lightGray
        tableView.register(RingtoneTableViewHeader.self, forHeaderFooterViewReuseIdentifier: headerId)
        tableView.register(RingtoneTableCell.self, forCellReuseIdentifier: cellId)
    }
    
    convenience init() {
        self.init(style: .plain)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: style)
        
        self.navigationItem.title = "Available Ringtones"
        self.tabBarItem = UITabBarItem(title: "Ringtones", image:nil , tag: 0)
        
        let selectedColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0)
        let unSelectedColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 0.4)
        self.tabBarItem.setFAIcon(icon: .FABellO, size: nil, textColor: unSelectedColor, backgroundColor: .clear, selectedTextColor: selectedColor, selectedBackgroundColor: .clear)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId) as! RingtoneTableViewHeader
        header.textLabel?.text = "TEST"
        header.backgroundColor = UIColor.white
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ringtoneStore.allRingtones.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! RingtoneTableCell
        
        let ringtone = ringtoneStore.allRingtones[indexPath.row]
        
        cell.textLabel?.text = ringtone.name
        cell.detailTextLabel?.text = ringtone.bundleID
        
        
        return cell
    }
    
    
}
