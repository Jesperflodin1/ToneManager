//libcephei prefs headers we need 
#import <CepheiPrefs/HBTintedTableCell.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBLinkTableCell.h>
#import <CepheiPrefs/HBTwitterCell.h>
#import <CepheiPrefs/HBImageTableCell.h>
#import <CepheiPrefs/HBPackageNameHeaderCell.h>
#import <CepheiPrefs/HBSupportController.h>

#import <SafariServices/SFSafariViewController.h>

#import <Preferences/PSSpecifier.h>

#import <TechSupport/TechSupport.h>

#import "../Log.h"

@class TSIncludeInstruction;

NS_ASSUME_NONNULL_BEGIN


@interface JFTHRootListController : HBRootListController

+ (nullable NSString *)hb_supportEmailAddress;
+ (nullable NSArray <TSIncludeInstruction *> *)hb_supportInstructions;
- (void)hb_sendSupportEmail;

- (void)hb_openURL:(PSSpecifier *)specifier;

@end

NS_ASSUME_NONNULL_END

@interface NSTask : NSObject

- (id)init;
- (void)launch;
- (void)setArguments:(id)arg1;
- (void)setLaunchPath:(id)arg1;
- (void)setStandardOutput:(id)arg1;
- (id)standardOutput;

@end
