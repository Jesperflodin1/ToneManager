#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

//libcephei prefs headers we need 
#import <CepheiPrefs/HBTintedTableCell.h>
#import <CepheiPrefs/HBRootListController.h>
#import <CepheiPrefs/HBLinkTableCell.h>
#import <CepheiPrefs/HBTwitterCell.h>
#import <CepheiPrefs/HBPackageNameHeaderCell.h>
#import <CepheiPrefs/HBSupportController.h>

#import <Cephei/HBPreferences.h>

#import <SafariServices/SFSafariViewController.h>
#import <TechSupport/TechSupport.h>


@interface NSTask : NSObject

- (id)init;
- (void)launch;
- (void)setArguments:(id)arg1;
- (void)setLaunchPath:(id)arg1;
- (void)setStandardOutput:(id)arg1;
- (id)standardOutput;

@end

@interface PSEditableListController : PSListController
@end
