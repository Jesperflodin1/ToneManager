//
//  ActionSheetGenerator.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-21.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import XLActionController
import BugfenderSDK
import PKHUD

class ActionSheetGenerator {
    
    class func ringtoneCellMenu(ringtoneCell : RingtoneTableCell, ringtoneTableController : RingtoneTableViewController) -> ActionController<ActionSheetCell, ActionData, UICollectionReusableView, Void, UICollectionReusableView, Void>? {
        
        guard let ringtone = ringtoneCell.ringtoneItem else { return nil }
        
        let actionController = ActionSheetController()
        
        if ringtone.installed {
            actionController.addAction(Action(ActionData(title: "Uninstall", image: ColorPalette.actionSheetMenuUninstall!), style: .default, handler: { action in
                
                RingtoneManager.uninstallRingtone(inCell: ringtoneCell) {
                    RingtoneStore.sharedInstance.allRingtones.lockArray()
                    ringtoneTableController.tableView.reloadData()
                    RingtoneStore.sharedInstance.allRingtones.unlockArray()
                }
                
            }))
        } else {
            actionController.addAction(Action(ActionData(title: "Install", image: ColorPalette.actionSheetMenuInstall!), style: .default, handler: { action in
                
                RingtoneManager.installRingtone(inCell: ringtoneCell) {
                    RingtoneStore.sharedInstance.allRingtones.lockArray()
                    ringtoneTableController.tableView.reloadData()
                    RingtoneStore.sharedInstance.allRingtones.unlockArray()
                }
                
            }))
        }
        actionController.addAction(Action(ActionData(title: "Show details", image: ColorPalette.actionSheetMenuInfo!), style: .default, handler: { action in
            
            ringtoneTableController.performSegue(withIdentifier: "showDetailsFromCellLabel", sender: ringtoneCell)
            
        }))
        actionController.addAction(Action(ActionData(title: "Open source app", image: ColorPalette.actionSheetMenuExternallink!), style: .default, handler: { action in
            
            if !LSApplicationWorkspaceHandler.openApplication(withBundleID: ringtone.bundleID) {
                Bugfender.error("Failed to open app with LSApplicationWorkspace")
                HUD.flash(.labeledError(title: "Error", subtitle: "Failed to open app, is it installed?"), delay: 1.0)
            }
            
        }))
        actionController.addAction(Action(ActionData(title: "Assign to contact", image: ColorPalette.actionSheetMenuAddressbook!), style: .default, handler: { action in
            guard let assigner = RingtoneAssigner(ringtone: ringtone) else { return }
            
            ringtoneTableController.ringtoneAssigner = assigner
            ringtoneTableController.openContactPicker()
            
        }))
        actionController.addAction(Action(ActionData(title: "Assign as default ringtone", image: ColorPalette.actionSheetMenuMobile!), style: .default, handler: { action in
            guard let assigner = RingtoneAssigner(ringtone: ringtone) else { return }
            assigner.assignDefaultRingtone()
            
            HUD.allowsInteraction = true
            HUD.flash(.label("Set ringtone as default ringtone"), delay: 1.0)
        }))
        actionController.addAction(Action(ActionData(title: "Assign as default text tone", image: ColorPalette.actionSheetMenuMessage!), style: .default, handler: { action in
            guard let assigner = RingtoneAssigner(ringtone: ringtone) else { return }
            assigner.assignDefaultTextTone()
            
            HUD.flash(.label("Set ringtone as default text tone"), delay: 1.0)
            
        }))
        actionController.addAction(Action(ActionData(title: "Delete", image: ColorPalette.actionSheetMenuDelete!), style: .destructive, handler: { action in
            
            RingtoneManager.deleteRingtone(inCell: ringtoneCell) {
                if let index = ringtoneTableController.tableView.indexPath(for: ringtoneCell) {
                    
                    ringtoneTableController.tableView.deleteRows(at: [index], with: .automatic)
                    
                    RingtoneStore.sharedInstance.allRingtones.lockArray()
                    ringtoneTableController.tableView.reloadData()
                    RingtoneStore.sharedInstance.allRingtones.unlockArray()
                }
            }
            
        }))
        actionController.addAction(Action(ActionData(title: "Cancel", image: ColorPalette.actionSheetMenuCancel!), style: .cancel, handler: nil))
        
        return actionController
    }
    
}
