//
//  AppDelegate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK

/// Application execution start point
@UIApplicationMain
/// AppDelegate class
class AppDelegate: UIResponder, UIApplicationDelegate {

    /// reference to UIWindow
    var window: UIWindow?
    
    /// Enables remote logging if enabled in userdefaults
    func enableRemoteLogging() {
        if Preferences.remoteLogging {
            Bugfender.activateLogger("HId16MWO0WTn4W4zk1Ipb32RtNf43dN6")
            Bugfender.enableUIEventLogging() // optional, log user interactions automatically
            Bugfender.enableCrashReporting() // optional, log crashes automatically
            BFLog("Remote logging enabled")
        }
    }
    
    
    /// Sets default user settings for UserDefaults
    func registerDefaults() {
        Preferences.defaults.register(defaults: [
            Preferences.keys.autoInstall.rawValue : false,
            Preferences.keys.remoteLogging.rawValue : true,
            Preferences.keys.audikoLite.rawValue : true,
            Preferences.keys.audikoPro.rawValue : true,
            Preferences.keys.zedgeRingtones.rawValue : true
            ])
        
//        if !Preferences.audikoLiteInstalled {
//            Preferences.audikoLite = false
//        }
//        if !Preferences.audikoProInstalled {
//            Preferences.audikoPro = false
//        }
//        if !Preferences.zedgeRingtonesInstalled {
//            Preferences.zedgeRingtones = false
//        }
    }

    /// UIApplicationDelegate method. Called on application launch. Loads and sets rootviewcontroller from main storyboard
    ///
    /// - Parameters:
    ///   - application: Current UIApplication
    ///   - launchOptions: Not used here
    /// - Returns: always true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        registerDefaults()
        enableRemoteLogging()
        
        BFLog("App start") // use BFLog as you would use NSLog
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
//        self.window!.backgroundColor = UIColor.white
        
        BFLog("Loading main storyboard")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "JFTMNavigationController") as! UINavigationController
        
        self.window!.rootViewController = nvc
        self.window!.makeKeyAndVisible()
        
        application.statusBarStyle = .lightContent // .default
        
        return true
    }

    /// UIApplicationDelegate method.
    ///
    /// - Parameter application: Current UIApplication
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        UserDefaults.standard.synchronize()
    }

    /// UIApplicationDelegate method.
    ///
    /// - Parameter application: Current UIApplication
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        
    }

    /// UIApplicationDelegate method. Called when application will return from background
    ///
    /// - Parameter application: Current UIApplication
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        BFLog("App returning from background")
    }

    /// UIApplicationDelegate method. Called when application returns from background
    ///
    /// - Parameter application: Current UIApplication
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    /// UIApplicationDelegate method.
    ///
    /// - Parameter application: Current UIApplication
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        UserDefaults.standard.synchronize()
    }


}

