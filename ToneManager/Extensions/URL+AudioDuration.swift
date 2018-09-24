//
//  URL+AudioDuration.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-24.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK
import AVFoundation

extension URL {
    func audioDurationOfFile() -> Int {
        do {
            let avAudioPlayer = try AVAudioPlayer(contentsOf: self)
            let duration = avAudioPlayer.duration
            return NSNumber(value: round(duration)).intValue
        } catch {
            Bugfender.error("Error retrieving duration of file: \(error)")
        }
        return 0
    }
}
