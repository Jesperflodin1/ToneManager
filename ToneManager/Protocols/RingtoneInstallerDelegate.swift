//
//  RingtoneInstallerDelegate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

protocol RingtoneInstallerDelegate: class {

    func installDidFail(forRingtone: Ringtone)
}
