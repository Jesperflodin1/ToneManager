//libcephei prefs headers we need 
//#import <CepheiPrefs/HBListController.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import "../JFTHRingtoneDataController.h"

@interface PSEditableListController : PSListController
@end
@interface JFTHRingtoneListController : PSEditableListController {
    JFTHRingtoneDataController *_toneData;
}

- (id)readTestValue:(PSSpecifier*)specifier;

@end
