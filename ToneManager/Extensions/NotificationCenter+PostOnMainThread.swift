//
//  NotificationCenter+PostOnMainThread.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

extension NotificationCenter {
    func postMainThreadNotification(notification: Notification) {
        DispatchQueue.main.async { NotificationCenter.default.post(notification) }
    }
}
