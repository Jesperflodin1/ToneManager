//
//  AppearanceManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-18.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import SideMenu

class AppearanceManager {
    
    class func setDefaultAppearance(_ nvc : UINavigationController) {
//        let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
        
        setupNavBar(nvc)
        setupSideMenu(nvc)
    }
    fileprivate class func setupNavBar(_ nvc : UINavigationController) {
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
    
    fileprivate class func setupSideMenu(_ nvc:UINavigationController) {
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
}
