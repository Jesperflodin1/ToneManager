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
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
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
    
    /// UIApplicationDelegate method. Called on application launch. Loads and sets rootviewcontroller from main storyboard
    ///
    /// - Parameters:
    ///   - application: Current UIApplication
    ///   - launchOptions: Not used here
    /// - Returns: always true
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        Preferences.registerDefaults()
        enableRemoteLogging()
        let result = UIApplication.shared.canOpenURL(URL(string: "tonemanager://test")!)
        BFLog("URLTEST: \(result)")
        AppSetupManager.doSetupIfNeeded()
        
        BFLog("App start")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "JFTMNavigationController") as! UINavigationController
        
        AppearanceManager.setDefaultAppearance(nvc)
        
        self.window!.rootViewController = nvc
        self.window!.makeKeyAndVisible()
        
        application.statusBarStyle = .lightContent // .default
        
        if let options = launchOptions, let url = options[.url] as? URL, url.isFileURL {
            BFLog("Got url for file in appdidfinishlaunching")
            RingtoneManager.importRingtoneURL(url, onSuccess: {
                NotificationCenter.default.post(name: .ringtoneStoreDidReload, object: nil)
            })
        }
        
        
        return true
    }
    
    /// UIApplicationDelegate method.
    ///
    /// - Parameter application: Current UIApplication
    func applicationWillResignActive(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }
    
    /// UIApplicationDelegate method.
    ///
    /// - Parameter application: Current UIApplication
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    /// UIApplicationDelegate method. Called when application will return from background
    ///
    /// - Parameter application: Current UIApplication
    func applicationWillEnterForeground(_ application: UIApplication) {
        BFLog("App returning from background")
    }
    
    /// UIApplicationDelegate method. Called when application returns from background
    ///
    /// - Parameter application: Current UIApplication
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    /// UIApplicationDelegate method.
    ///
    /// - Parameter application: Current UIApplication
    func applicationWillTerminate(_ application: UIApplication) {
        UserDefaults.standard.synchronize()
    }
    
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.isFileURL {
            BFLog("Got url for file from another app")
            RingtoneManager.importRingtoneURL(url, onSuccess: {
                NotificationCenter.default.post(name: .ringtoneStoreDidReload, object: nil)
            })
        }
        return true // if successful
    }
}

