//
//  UIImageView+Rotate.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-23.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//



extension UIImageView {
    func rotate(withAngle angle: CGFloat, animated: Bool) {
        UIView.animate(withDuration: animated ? 0.5 : 0, animations: {
            self.transform = CGAffineTransform(rotationAngle: angle)
        })
    }
}
