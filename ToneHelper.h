#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JGProgressHUD/JGProgressHUD.h"

#include "stdio.h"
#include "dlfcn.h"

@interface TKTonePickerViewController : UITableViewController
@property NSString *selectedVibrationIdentifier;
@end

@interface TKTonePickerController : NSObject
@property TKTonePickerViewController *delegate;
@end