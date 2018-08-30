@interface Ringtones.RingtoneGuideCell: UICollectionViewCell  
{
	__unknown__ onSelect;
	__unknown__ textLabel;
	__unknown__ textLabelBackground;
}

@property (non-atomic, copy) id (^block)(...) onSelect;
@property (non-atomic, __weak) UILabel * textLabel;
@property (non-atomic, __weak) UIView * textLabelBackground;
@end
 -(void)setOnSelect:(id (^block)(...))arg1;
 -(id)textLabelBackground;
 -(void)setTextLabelBackground:(id)arg1;
 -(void)cellTapped; // HOOK
 -(id)initWithFrame:(CGRect)arg1;
 -(id (^block)(...)).cxx_destruct;
 -(id)initWithCoder:(id)arg1;
 -(void)awakeFromNib;
 -(id)textLabel;
 -(void)setTextLabel:(id)arg1;
 -(id (^block)(...))onSelect;