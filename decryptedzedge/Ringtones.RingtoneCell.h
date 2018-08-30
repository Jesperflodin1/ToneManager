@interface Ringtones.RingtoneCell: UICollectionViewCell  
{
	__unknown__ closeButton;
	__unknown__ titleLabel;
	__unknown__ upperTitleLabel;
	__unknown__ tagsLabel;
	__unknown__ downloadButton;
	__unknown__ shareButton;
	__unknown__ infoButton;
	__unknown__ lengthIndicator;
	__unknown__ activityIndicator;
	__unknown__ pauseButton;
	__unknown__ itemColor;
}

@property (non-atomic, __weak) UIButton * closeButton;
@property (non-atomic, __weak) UILabel * titleLabel;
@property (non-atomic, __weak) UILabel * upperTitleLabel;
@property (non-atomic, __weak) UILabel * tagsLabel;
@property (non-atomic, __weak) UIButton * downloadButton;
@property (non-atomic, __weak) UIButton * shareButton;
@property (non-atomic, __weak) UIButton * infoButton;
@property (non-atomic, __weak) _TtCRingtonesLengthIndicatorView * lengthIndicator;
@property (non-atomic, __weak) UIActivityIndicatorView * activityIndicator;
@property (non-atomic, __weak) UIButton * pauseButton;
@property (non-atomic, retain) UIColor * itemColor;
@end
 -(id)upperTitleLabel;
 -(void)setUpperTitleLabel:(id)arg1;
 -(id)lengthIndicator;
 -(void)setLengthIndicator:(id)arg1;
 -(id)itemColor;
 -(void)setItemColor:(id)arg1;
 -(void)setOpenedState:(BOOL)arg1;
 -(id)initWithFrame:(CGRect)arg1;
 -(id (^block)(...)).cxx_destruct;
 -(id)initWithCoder:(id)arg1;
 -(void)reset;
 -(id)titleLabel;
 -(void)awakeFromNib;
 -(void)prepareForReuse;
 -(id)activityIndicator;
 -(void)setActivityIndicator:(id)arg1;
 -(id)infoButton;
 -(void)setInfoButton:(id)arg1;
 -(void)setTitleLabel:(id)arg1;
 -(void)setShareButton:(id)arg1;
 -(id)shareButton;
 -(void)setCloseButton:(id)arg1;
 -(id)closeButton;
 -(id)downloadButton;
 -(id)tagsLabel;
 -(void)setDownloadButton:(id)arg1;
 -(void)setTagsLabel:(id)arg1;
 -(id)pauseButton;
 -(void)setPauseButton:(id)arg1;