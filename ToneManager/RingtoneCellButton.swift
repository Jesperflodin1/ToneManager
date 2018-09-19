//
//  RingtoneCellButton.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-19.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit

class RingtoneCellButton: UIButton {
    
    var addedTouchArea = CGFloat(0)
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
        let newBound = CGRect(
            x: self.bounds.origin.x - addedTouchArea,
            y: self.bounds.origin.y - addedTouchArea,
            width: self.bounds.width + 2 * addedTouchArea,
            height: self.bounds.width + 2 * addedTouchArea
        )
        return newBound.contains(point)
    }

}
