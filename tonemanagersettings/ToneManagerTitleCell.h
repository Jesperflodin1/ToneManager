//
//  ToneManagerTitleCell.h
//  
//
//  Created by Jesper Flodin on 2018-09-28.
//

#import <UIKit/UIKit.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface PSTableCell ()
- (id)initWithStyle:(int)style reuseIdentifier:(id)arg2;
@end

@interface ToneManagerTitleCell : PSTableCell {
    UILabel *tweakTitle;
    UILabel *tweakSubtitle;
}

@end
