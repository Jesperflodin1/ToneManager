@interface Ringtones.RingtoneGuideContentViewController: UIViewController  
{
	__unknown__ contentImage;
	__unknown__ upperLabel;
	__unknown__ lowerLabel;
	__unknown__ assets;
	__unknown__ pageIndex;
	__unknown__ paragraphSpacing;
	__unknown__ lineSpacing;
}

@property (non-atomic, __weak) UIImageView * contentImage;
@property (non-atomic, __weak) UILabel * upperLabel;
@property (non-atomic, __weak) UILabel * lowerLabel;
@end
 +(id)create;
 -(id)upperLabel;
 -(void)setUpperLabel:(id)arg1;
 -(id)lowerLabel;
 -(void)setLowerLabel:(id)arg1;
 -(void)setContentImage:(id)arg1;
 -(id (^block)(...)).cxx_destruct;
 -(id)initWithCoder:(id)arg1;
 -(id)initWithNibName:(id)arg1 bundle:(id)arg2;
 -(void)viewDidLoad;
 -(id)contentImage;