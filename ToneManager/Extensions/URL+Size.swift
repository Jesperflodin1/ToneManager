//
//  URL+Size.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation
import BugfenderSDK

extension URL {
    func size() -> Int? {
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: self.path)
            if let size = attribute[FileAttributeKey.size] as? Int {
                return size
            }
        } catch {
            Bugfender.error("Failed to get filesize for path: \(self.path)")
        }
        return nil
    }
}
