//
//  TabBarViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class TabBarController : UITabBarController {
    override func viewDidLoad() {
        let ringtoneStore = RingtoneStore()
        let ringtoneTableViewController = RingtoneTableViewController()
        ringtoneTableViewController.ringtoneStore = ringtoneStore
        
        let settingsViewController = SettingsViewController()
        
        let viewControllerList = [ringtoneTableViewController, settingsViewController]
        
        viewControllers = viewControllerList.map { UINavigationController(rootViewController: $0) }
    }
}
