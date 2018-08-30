@interface Ringtones.RingtoneGuideViewController: UIViewController <UIPageViewControllerDelegate,UIPageViewControllerDataSource> 
{
	__unknown__ onDismiss;
	__unknown__ pageIndicator;
	__unknown__ closeButton;
	__unknown__ pageViewController;
	__unknown__ pageContents;
}

@property (non-atomic, copy) id (^block)(...) onDismiss;
@property (non-atomic, __weak) UIPageControl * pageIndicator;
@property (non-atomic, __weak) UIButton * closeButton;
@end
 +(id)create;
 -(void)pageViewController:(id)arg1 willTransitionToViewControllers:(id)arg2;
 -(void)pageViewController:(id)arg1 didFinishAnimating:(BOOL)arg2 previousViewControllers:(id)arg3 transitionCompleted:(BOOL)arg4;
 -(id)pageViewController:(id)arg1 viewControllerBeforeViewController:(id)arg2;
 -(id)pageViewController:(id)arg1 viewControllerAfterViewController:(id)arg2;
 -(id)pageIndicator;
 -(void)setPageIndicator:(id)arg1;
 -(void)dismissGuide:(id)arg1;
 -(id (^block)(...)).cxx_destruct;
 -(id)initWithCoder:(id)arg1;
 -(id)initWithNibName:(id)arg1 bundle:(id)arg2;
 -(void)viewDidLoad;
 -(id (^block)(...))onDismiss;
 -(void)setOnDismiss:(id (^block)(...))arg1;
 -(void)setCloseButton:(id)arg1;
 -(id)closeButton;