#include "JFTHRootListController.h"
#import <Cephei/HBRespringController.h>
#import "../Log.h"

@implementation JFTHRootListController

+ (NSString *)hb_specifierPlist {
	return @"Root";
}
+ (NSString *)hb_shareText {
	return nil;
}

+ (NSURL *)hb_shareURL {
	return nil;
}

- (void)respring:(PSSpecifier *)specifier {
	PSTableCell *cell = [self cachedCellForSpecifier:specifier];

	// disable the cell, in case it takes a moment
	cell.cellEnabled = NO;
/*
	// ask for the url to be generated
	[(PreferencesAppController *)[UIApplication sharedApplication] generateURL];

	// sadly, this is stored in the preferences…
	NSString *position = (__bridge NSString *)CFPreferencesCopyAppValue(CFSTR("kPreferencePositionKey"), kCFPreferencesCurrentApplication);
*/
	// call the main method
	[HBRespringController respring];
}

@end
