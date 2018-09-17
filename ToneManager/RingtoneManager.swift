//
//  RingtoneManager.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

class RingtoneManager {
  /// Storage for Ringtones
  fileprivate var ringtoneStore : RingtoneStore!
  
  init() {
    ringtoneStore = RingtoneStore.sharedInstance
  }
}
