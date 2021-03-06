//
//  ToneManagerTitleCell.m
//  
//
//  Created by Jesper Flodin on 2018-09-28.
//

#import "ToneManagerTitleCell.h"

@implementation ToneManagerTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(id)reuseIdentifier specifier:(id)specifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
    
    if (self) {
        
        int width = self.contentView.bounds.size.width;
        
        CGRect frame = CGRectMake(0, 20, width, 60);
        CGRect subtitleFrame = CGRectMake(0, 55, width, 60);
        
        tweakTitle = [[UILabel alloc] initWithFrame:frame];
        [tweakTitle setNumberOfLines:1];
        [tweakTitle setFont:[UIFont fontWithName:@"HelveticaNeue-UltraLight" size:48]];
        [tweakTitle setText:@"ToneManager"];
        [tweakTitle setBackgroundColor:[UIColor clearColor]];
        [tweakTitle setTextColor:[UIColor blackColor]];
        [tweakTitle setTextAlignment:NSTextAlignmentCenter];
        tweakTitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tweakTitle.contentMode = UIViewContentModeScaleToFill;
        
        tweakSubtitle = [[UILabel alloc] initWithFrame:subtitleFrame];
        [tweakSubtitle setNumberOfLines:1];
        [tweakSubtitle setFont:[UIFont fontWithName:@"HelveticaNeue-Regular" size:18]];
        [tweakSubtitle setText:@"by Jesper Flodin"];
        [tweakSubtitle setBackgroundColor:[UIColor clearColor]];
        [tweakSubtitle setTextColor:[UIColor colorWithRed:119/255.0f green:119/255.0f blue:122/255.0f alpha:1.0f]];
        [tweakSubtitle setTextAlignment:NSTextAlignmentCenter];
        tweakSubtitle.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tweakSubtitle.contentMode = UIViewContentModeScaleToFill;
        
        [self addSubview:tweakTitle];
        [self addSubview:tweakSubtitle];
    }
    
    return self;
}

- (instancetype)initWithSpecifier:(PSSpecifier *)specifier {
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ToneManagerTitleCell" specifier:specifier];
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x = 0;
    [super setFrame:frame];
}

- (CGFloat)preferredHeightForWidth:(CGFloat)arg1{
    return 125.0f;
}

- (CGFloat)preferredHeightForWidth:(CGFloat)width inTableView:(id)tableView {
    return [self preferredHeightForWidth:width];
}


@end
