@interface Ringtones.SavedRingtoneCell: Ringtones.RingtoneCell  
{
	UILabel fileNameLabel;
	__unknown__ contentLeadingConstraint;
	UIImageView markImageView;
	__unknown__ markImageViewLeadingConstraint;
}

@property (non-atomic, __weak) UILabel * fileNameLabel;
@property (non-atomic, __weak) NSLayoutConstraint * contentLeadingConstraint;
@property (non-atomic, __weak) UIImageView * markImageView;
@property (non-atomic, __weak) NSLayoutConstraint * markImageViewLeadingConstraint;
@property (non-atomic) BOOL selected;
@end
 -(id)fileNameLabel;
 -(void)setFileNameLabel:(id)arg1;
 -(id)markImageView;
 -(void)setMarkImageView:(id)arg1;
 -(id)markImageViewLeadingConstraint;
 -(void)setMarkImageViewLeadingConstraint:(id)arg1;
 -(void)setEditModeEnabled:(BOOL)arg1 animated:(BOOL)arg2;
 -(id)initWithFrame:(CGRect)arg1;
 -(id (^block)(...)).cxx_destruct;
 -(id)initWithCoder:(id)arg1;
 -(void)reset;
 -(void)awakeFromNib;
 -(BOOL)isSelected;
 -(void)prepareForReuse;
 -(void)setSelected:(BOOL)arg1;
 -(void)setContentLeadingConstraint:(id)arg1;
 -(id)contentLeadingConstraint;