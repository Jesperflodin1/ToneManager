#import "ToneHelper.h"

%hook AUSelectedRingtoneViewController

-(void)viewDidLoad {
	%orig;
	UIAlertController* alert = [UIAlertController 
		alertControllerWithTitle:@"DEBUG"
                         message:@"This is an alert. Thanks"
                  preferredStyle:UIAlertControllerStyleAlert
	];
 
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK..." 
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {}
	];
	
	[alert addAction:defaultAction];
	[self presentViewController:alert animated:YES completion:nil];
}

%end
