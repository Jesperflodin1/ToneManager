//
//  NSTextAttachment+setImageHeight.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-27.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

extension NSTextAttachment {
    func setImageHeight(height: CGFloat) {
        guard let image = image else { return }
        let ratio = image.size.width / image.size.height
        
        bounds = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: ratio * height, height: height)
    }
}
