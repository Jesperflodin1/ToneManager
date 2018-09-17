//
//  AppDelegate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import BugfenderSDK
import SideMenu

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
  
  fileprivate func setupSideMenu(_ nvc:UINavigationController) {
    // Define the menus
    SideMenuManager.default.menuLeftNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
    
    // Enable gestures. The left and/or right menus must be set up above for these to work.
    // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
    SideMenuManager.default.menuAddPanGestureToPresent(toView: nvc.navigationBar)
    SideMenuManager.default.menuAddScreenEdgePanGesturesToPresent(toView: nvc.view, forMenu: UIRectEdge.left)
    
    // Set up a cool background image for demo purposes
    SideMenuManager.default.menuAnimationBackgroundColor = UIColor(patternImage: ColorPalette.sideMenuBackground!)
    
    SideMenuManager.default.menuPresentMode = .viewSlideOut
    SideMenuManager.default.menuBlurEffectStyle = UIBlurEffectStyle.dark
    SideMenuManager.default.menuFadeStatusBar = false
    SideMenuManager.default.menuShadowOpacity = 0.8
    SideMenuManager.default.menuAnimationFadeStrength = 0
  }
  
  fileprivate func setupNavBar(_ nvc : UINavigationController) {
    UINavigationBar.appearance().setBackgroundImage(ColorPalette.navBarBackground?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), for: .default)
    UINavigationBar.appearance().isTranslucent = true
    
    if let font = ColorPalette.navBarTitleFont {
      UINavigationBar.appearance().titleTextAttributes = [
        NSAttributedStringKey.font: font,
        NSAttributedStringKey.foregroundColor: ColorPalette.navBarTextColor]
    }
    
    nvc.toolbar.setBackgroundImage(ColorPalette.navBarBackground?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), forToolbarPosition: .any, barMetrics: .default)
    nvc.toolbar.isTranslucent = true
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
    
    BFLog("Loading main storyboard")
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let nvc = storyboard.instantiateViewController(withIdentifier: "JFTMNavigationController") as! UINavigationController
    
    setupNavBar(nvc)
    setupSideMenu(nvc)
    
    self.window!.rootViewController = nvc
    self.window!.makeKeyAndVisible()
    
    application.statusBarStyle = .lightContent // .default
    
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
  
  
}

