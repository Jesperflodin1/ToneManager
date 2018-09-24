//
//  ActionSheetCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-19.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

import UIKit
import XLActionController

open class ActionSheetCell: ActionCell {
    
    open lazy var animatableBackgroundView: UIView = { [weak self] in
        let view = UIView(frame: self?.frame ?? CGRect.zero)
        view.backgroundColor = UIColor.red.withAlphaComponent(0.40)
        return view
        }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    func initialize() {
        actionTitleLabel?.textColor = UIColor(white: 0.098, alpha: 1.0)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        backgroundView.addSubview(animatableBackgroundView)
        selectedBackgroundView = backgroundView
    }
    
    open override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                animatableBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
                animatableBackgroundView.frame = CGRect(x: 0, y: 0, width: 30, height: frame.height)
                animatableBackgroundView.center = CGPoint(x: frame.width * 0.5, y: frame.height * 0.5)
                
                UIView.animate(withDuration: 0.5) { [weak self] in
                    guard let me  = self else {
                        return
                    }
                    
                    me.animatableBackgroundView.frame = CGRect(x: 0, y: 0, width: me.frame.width, height: me.frame.height)
                    me.animatableBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.08)
                }
            } else {
                animatableBackgroundView.backgroundColor = animatableBackgroundView.backgroundColor?.withAlphaComponent(0.0)
            }
        }
    }
}
