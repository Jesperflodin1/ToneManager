//
//  URL+RingtoneName.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import Foundation

extension URL {
    func nameFromFilePath() -> String {
        let filename = self.fileNameWithoutExtension()
        
        let characterSet = CharacterSet(charactersIn: " ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-").inverted
        let components = filename.components(separatedBy: characterSet)
        let name = components.joined(separator: "")
        
        return name.condenseWhitespace()
    }
    func fileNameWithoutExtension() -> String {
        return self.deletingPathExtension().lastPathComponent
    }
    func changingPathExtension(_ pathExtension : String) -> URL {
        return self.deletingPathExtension().appendingPathExtension(pathExtension)
    }
    func m4r() -> Bool {
        return self.pathExtension == "m4r"
    }
}

