//
//  AppListCellDelegate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-21.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

protocol AppListCellDelegate: class {
    
    func valueDidChange(_ value : Bool, appIdentifier : String)
    
}
