//
//  AppListViewDataSource.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-21.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK

class AppListViewDataSource : ALApplicationTableDataSource, ALValueCellDelegate, UITableViewDelegate {
    
    var controller : AppListViewController
    
    override init!() {
        super.init()
    }
    
    convenience init(WithController controller : AppListViewController) {
        self.init()
        self.controller = controller
    }
    
    func valueCell(_ valueCell: ALValueCell!, didChangeToValue newValue: Any!) {
        <#code#>
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let switchCell = cell as? ALSwitchCell {
            switchCell.delegate = self
            switchCell.loadValue(controller, withTitle: <#T##String!#>)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        <#code#>
    }
    
    
}
