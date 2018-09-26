//
//  AppearanceManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-18.
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
import SideMenu
import PopupDialog

class AppearanceManager {
    
    class func setDefaultAppearance(_ nvc : UINavigationController) {
//        let navigationController = UIApplication.shared.windows[0].rootViewController as! UINavigationController
        
        setupNavBar(nvc)
        setupSideMenu(nvc)
//        setupPopups()
    }
    fileprivate class func setupNavBar(_ nvc : UINavigationController) {
        UINavigationBar.appearance().setBackgroundImage(ColorPalette.navBarBackground?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0), resizingMode: .stretch), for: .default)
        UINavigationBar.appearance().isTranslucent = true
        UINavigationBar.appearance().tintColor = UIColor.white
        
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
    
    fileprivate class func setupPopups() {
        let dialogAppearance = PopupDialogDefaultView.appearance()
        
        dialogAppearance.backgroundColor      = .white
        dialogAppearance.titleFont            = .boldSystemFont(ofSize: 14)
        dialogAppearance.titleColor           = UIColor(white: 0.4, alpha: 1)
        dialogAppearance.titleTextAlignment   = .center
        dialogAppearance.messageFont          = .systemFont(ofSize: 14)
        dialogAppearance.messageColor         = UIColor(white: 0.6, alpha: 1)
        dialogAppearance.messageTextAlignment = .center
        
        let containerAppearance = PopupDialogContainerView.appearance()
        
        containerAppearance.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        containerAppearance.cornerRadius    = 2
        containerAppearance.shadowEnabled   = true
        containerAppearance.shadowColor     = .black
        containerAppearance.shadowOpacity   = 0.6
        containerAppearance.shadowRadius    = 20
        containerAppearance.shadowOffset    = CGSize(width: 0, height: 8)
//        containerAppearance.shadowPath      = CGPath(...)
        
        let overlayAppearance = PopupDialogOverlayView.appearance()
        
        overlayAppearance.color           = .black
        overlayAppearance.blurRadius      = 20
        overlayAppearance.blurEnabled     = true
        overlayAppearance.liveBlurEnabled = false
        overlayAppearance.opacity         = 0.7
        
        let buttonAppearance = DefaultButton.appearance()
        
        // Default button
        buttonAppearance.titleFont      = .systemFont(ofSize: 14)
        buttonAppearance.titleColor     = UIColor(red: 0.25, green: 0.53, blue: 0.91, alpha: 1)
        buttonAppearance.buttonColor    = .clear
        buttonAppearance.separatorColor = UIColor(white: 0.9, alpha: 1)
        
        // Below, only the differences are highlighted
        
        // Cancel button
        CancelButton.appearance().titleColor = .lightGray
        
        // Destructive button
        DestructiveButton.appearance().titleColor = .red
    }
    
    fileprivate class func setPopupDarkmode() {
        // Customize dialog appearance
        let pv = PopupDialogDefaultView.appearance()
        pv.titleFont    = UIFont(name: "HelveticaNeue-Light", size: 16)!
        pv.titleColor   = .white
        pv.messageFont  = UIFont(name: "HelveticaNeue", size: 14)!
        pv.messageColor = UIColor(white: 0.8, alpha: 1)
        
        // Customize the container view appearance
        let pcv = PopupDialogContainerView.appearance()
        pcv.backgroundColor = UIColor(red:0.23, green:0.23, blue:0.27, alpha:1.00)
        pcv.cornerRadius    = 2
        pcv.shadowEnabled   = true
        pcv.shadowColor     = .black
        
        // Customize overlay appearance
        let ov = PopupDialogOverlayView.appearance()
        ov.blurEnabled     = true
        ov.blurRadius      = 30
        ov.liveBlurEnabled = true
        ov.opacity         = 0.7
        ov.color           = .black
        
        // Customize default button appearance
        let db = DefaultButton.appearance()
        db.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        db.titleColor     = .white
        db.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        db.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        // Customize cancel button appearance
        let cb = CancelButton.appearance()
        cb.titleFont      = UIFont(name: "HelveticaNeue-Medium", size: 14)!
        cb.titleColor     = UIColor(white: 0.6, alpha: 1)
        cb.buttonColor    = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cb.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
    }
}
