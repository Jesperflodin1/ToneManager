//
//  SettingsViewController.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK

/// <#Description#>
class SettingsViewController : UITableViewController {
    
//    override func viewDidLoad() {
////        if #available(iOS 11.0, *) {
////            BFLog("viewDidLoad, >=iOS 11")
////            navigationController?.navigationBar.prefersLargeTitles = true
////            navigationController?.navigationItem.largeTitleDisplayMode = .always
////        } else {
////            BFLog("viewDidLoad, <iOS 11")
////        }
//        
//    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func githubTapped(_ sender: UITapGestureRecognizer) {
        BFLog("Github!")
    }

    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func redditTapped(_ sender: UITapGestureRecognizer) {
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func paypalTapped(_ sender: UITapGestureRecognizer) {
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func twitterTapped(_ sender: UITapGestureRecognizer) {
    }
    
    /// <#Description#>
    ///
    /// - Parameter sender: <#sender description#>
    @IBAction func emailTapped(_ sender: UITapGestureRecognizer) {
    }
}
