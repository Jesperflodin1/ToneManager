//
//  AppDelegate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// <#Description#>
    ///
    /// - Parameters:
    ///   - application: <#application description#>
    ///   - launchOptions: <#launchOptions description#>
    /// - Returns: <#return value description#>
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Bugfender.activateLogger("HId16MWO0WTn4W4zk1Ipb32RtNf43dN6")
        Bugfender.enableUIEventLogging() // optional, log user interactions automatically
        Bugfender.enableCrashReporting() // optional, log crashes automatically
        BFLog("App start") // use BFLog as you would use NSLog
        
        let fileManager = FileManager.default
        let appDataDir = URL(fileURLWithPath: "/var/mobile/Library/ToneManager")
        if !fileManager.fileExists(atPath: appDataDir.path) {
            BFLog("No app data directory found, creating")
            do {
                try fileManager.createDirectory(atPath: appDataDir.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                BFLog("JFTM: Couldn't create document directory")
            }
        } else {
            BFLog("App data directory exists")
        }
        
        self.window = UIWindow(frame: UIScreen.main.bounds)

        self.window!.backgroundColor = UIColor.white
        
        BFLog("Loading main storyboard")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "JFTMNavigationController") as! UINavigationController
        let vc = nvc.topViewController as! RingtoneTableViewController
        vc.ringtoneStore = RingtoneStore()
        
        self.window!.rootViewController = nvc
        self.window!.makeKeyAndVisible()
        
        application.statusBarStyle = .lightContent // .default
        
        return true
    }

    /// <#Description#>
    ///
    /// - Parameter application: <#application description#>
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    /// <#Description#>
    ///
    /// - Parameter application: <#application description#>
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    /// <#Description#>
    ///
    /// - Parameter application: <#application description#>
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    /// <#Description#>
    ///
    /// - Parameter application: <#application description#>
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    /// <#Description#>
    ///
    /// - Parameter application: <#application description#>
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

