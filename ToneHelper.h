#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JGProgressHUD/JGProgressHUD.h"

#import <FrontBoard/FBApplicationInfo.h>
#import <SpringBoard/SpringBoard.h>

#include "stdio.h"
#include "dlfcn.h"

typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};

@interface TKTonePickerViewController : UITableViewController
@end

@interface TKTonePickerController : NSObject
- (NSString *)JFTH_RandomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;
@end

@interface LSApplicationProxy
/*MobileCoreServices*/
- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
+ (id)applicationProxyForIdentifier:(NSString *)arg1;
+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
@end
/*
@interface SpringBoard : UIApplication {
    dispatch_source_t _source;
    NSArray* mFiles;
    NSString* mPath;
}
@end*/

/*@interface FBApplicationInfo : NSObject
- (NSURL *)dataContainerURL;
- (NSURL *)bundleURL;
- (NSString *)bundleIdentifier;
- (NSString *)bundleType;
- (NSString *)bundleVersion;
- (NSString *)displayName;
- (id)initWithApplicationProxy:(id)arg1;
@end*/