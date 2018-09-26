//
//  HelpTableViewCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-22.
//
//
//  MIT License
//
//  Copyright (c) 2018 Jesper Flodin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

class HelpTableViewCell : UITableViewCell {
    
    @IBOutlet weak var cellHeaderView: UIView!
    @IBOutlet weak var cellHeaderTitle: UILabel!
    @IBOutlet weak var cellHeaderImage: UIImageView!
    @IBOutlet weak var cellBodyText: UITextView!
    
    override func awakeFromNib() {
        cellHeaderView.layer.shadowOffset = CGSize(width: 0, height: 0)
        cellHeaderView.layer.shadowColor = UIColor.black.cgColor
        cellHeaderView.layer.shadowOpacity = 0.75
        cellHeaderView.layer.shadowRadius = 4
        cellHeaderView.layer.shadowOpacity = 0.25
        cellHeaderView.layer.masksToBounds = false;
        cellHeaderView.clipsToBounds = false;
        cellHeaderView.layer.cornerRadius = 12
        
        cellHeaderImage.image = ColorPalette.cellDownArrow
        
        cellBodyText.layer.shadowOffset = CGSize(width: 0, height: 0)
        cellBodyText.layer.shadowColor = UIColor.black.cgColor
        cellBodyText.layer.shadowOpacity = 0.75
        cellBodyText.layer.shadowRadius = 4
        cellBodyText.layer.shadowOpacity = 0.25
        cellBodyText.layer.masksToBounds = false;
        cellBodyText.clipsToBounds = false;
        cellBodyText.layer.cornerRadius = 12
        cellBodyText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 5)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellHeaderTitle.text = nil
        cellBodyText.text = nil
        cellBodyText.attributedText = nil
        cellHeaderImage.image = ColorPalette.cellDownArrow
    }
    
    func setValues(_ data : HelpItem) {
        cellHeaderTitle.text = data.title
        if let text = data.text {
            cellBodyText.text = text
        } else if let attributed = data.attributedText {
            cellBodyText.attributedText = attributed
        }
        
        let shown = data.textShown
        
        cellBodyText.isHidden = !shown
        
        cellHeaderImage.image = shown ? ColorPalette.cellUpArrow : ColorPalette.cellDownArrow
        
        
    }
}
