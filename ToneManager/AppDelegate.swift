//
//  AppDelegate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//
//
//  MIT License
//
//  Copyright (c) 2018 Jesper Flodin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
        
        BFLog("App start")
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nvc = storyboard.instantiateViewController(withIdentifier: "JFTMNavigationController") as! UINavigationController
        
        AppearanceManager.setDefaultAppearance(nvc)
        
        self.window!.rootViewController = nvc
        self.window!.makeKeyAndVisible()
        
        application.statusBarStyle = .lightContent // .default
        
        let result = UIApplication.shared.canOpenURL(URL(string: "tonemanager://test")!)
        BFLog("URLTEST: %d", result)
        AppSetupManager.doSetupIfNeeded()
        
        if let options = launchOptions, let url = options[.url] as? URL, url.isFileURL {
            BFLog("Got url for file in appdidfinishlaunching")
            RingtoneManager.importRingtoneURL(url, onSuccess: {
                NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
            })
        }
        
//        let app = FBApplicationInfoHandler.applicationProxy(forBundleIdentifier: "com.908.Audiko")
//        BFLog("Approxy test: %@", (app?.applicationType())!)
        AppSetupManager.report_memory()
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
        AppSetupManager.clearTempFolder()
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
        AppSetupManager.clearTempFolder()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.isFileURL {
            BFLog("Got url for file from another app")
            RingtoneManager.importRingtoneURL(url, onSuccess: {
                NotificationCenter.default.postMainThreadNotification(notification: Notification(name: .ringtoneStoreDidReload))
            })
        }
        return true // if successful
    }
    
    
}

