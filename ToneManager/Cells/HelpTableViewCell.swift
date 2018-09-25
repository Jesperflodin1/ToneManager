//
//  HelpTableViewCell.swift
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-22.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

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
        cellBodyText.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellHeaderTitle.text = ""
        cellBodyText.text = ""
        cellHeaderImage.image = ColorPalette.cellDownArrow
    }
    
    func setValues(_ data : HelpItem) {
        cellHeaderTitle.text = data.title
        cellBodyText.text = data.text
        
        let shown = data.textShown
        
        cellBodyText.isHidden = !shown
        
        cellHeaderImage.image = shown ? ColorPalette.cellUpArrow : ColorPalette.cellDownArrow
        
        
    }
}
