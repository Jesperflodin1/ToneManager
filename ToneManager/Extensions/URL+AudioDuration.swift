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
        return NSNumber(value: round(self.rawAudioDurationOfFile())).intValue
    }
    func rawAudioDurationOfFile() -> Double {
        do {
            let avAudioPlayer = try AVAudioPlayer(contentsOf: self)
            return avAudioPlayer.duration
        } catch {
            Bugfender.error("Error retrieving duration of file: \(error)")
        }
        return 0
    }
}
