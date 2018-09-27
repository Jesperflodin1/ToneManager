//
//  URL+Directories.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-27.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

extension URL {
    var isDirectory: Bool {
        return (try? resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true
    }
    var subDirectories: [URL] {
        guard isDirectory else { return [] }
        return (try? FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles]).filter{ $0.isDirectory }) ?? []
    }
}
