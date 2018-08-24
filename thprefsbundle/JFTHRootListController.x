#include "JFTHRootListController.h"
#import <Cephei/HBRespringController.h>
#include <version.h>

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

- (id)specifiers {
    [super specifiers];
	NSBundle *prefBundle = [NSBundle bundleWithIdentifier:@"fi.flodin.thprefsbundle"];

    PSSpecifier* githubSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Visit Github Page"
                                                        target:self
                                                           set:NULL
                                                           get:NULL
                                                        detail:Nil
                                                          cell:PSLinkCell
                                                          edit:Nil];
	githubSpecifier->action = @selector(hb_openURL:);
	[githubSpecifier setProperty:NSClassFromString(@"HBLinkTableCell") forKey:@"cellClass"];
	[githubSpecifier setProperty:@"Source code and Issues" forKey:@"subtitle"];
	[githubSpecifier setProperty:@YES forKey:@"enabled"];
	[githubSpecifier setProperty:@"https://github.com/Jesperflodin1/tonehelper" forKey:@"url"];
	[githubSpecifier setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"GitHub" ofType:@"png"]] forKey:@"iconImage"];
	//[githubSpecifier setProperty:NSStringFromSelector(@selector(hb_openURL:)) forKey:@"action"];

	PSSpecifier* redditSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Contact me on Reddit"
                                                        target:self
                                                           set:NULL
                                                           get:NULL
                                                        detail:Nil
                                                          cell:PSLinkCell
                                                          edit:Nil];
	redditSpecifier->action = @selector(hb_openURL:);
	[redditSpecifier setProperty:NSClassFromString(@"HBLinkTableCell") forKey:@"cellClass"];
	[redditSpecifier setProperty:@"Contact me on Reddit" forKey:@"subtitle"];
	[redditSpecifier setProperty:@YES forKey:@"enabled"];
	[redditSpecifier setProperty:@"https://www.reddit.com/user/jesperflodin1" forKey:@"url"];
	[redditSpecifier setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"Reddit" ofType:@"png"]] forKey:@"iconImage"];
	//[redditSpecifier setProperty:NSStringFromSelector(@selector(hb_openURL:)) forKey:@"action"];

	PSSpecifier* donateSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Donate"
                                                        target:self
                                                           set:NULL
                                                           get:NULL
                                                        detail:Nil
                                                          cell:PSLinkCell
                                                          edit:Nil];
	donateSpecifier->action = @selector(hb_openURL:);
	[donateSpecifier setProperty:NSClassFromString(@"HBLinkTableCell") forKey:@"cellClass"];
	[donateSpecifier setProperty:@"If you like this tweak, please consider a donation." forKey:@"subtitle"];
	[donateSpecifier setProperty:@YES forKey:@"enabled"];
	[donateSpecifier setProperty:@"https://www.paypal.me/Jesperflodin" forKey:@"url"];
	[donateSpecifier setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"paypal" ofType:@"png"]] forKey:@"iconImage"];
	//[donateSpecifier setProperty:NSStringFromSelector(@selector(hb_openURL:)) forKey:@"action"];

	PSSpecifier* emailSpecifier = [PSSpecifier preferenceSpecifierNamed:@"Email me"
                                                        target:self
                                                           set:NULL
                                                           get:NULL
                                                        detail:Nil
                                                          cell:PSLinkCell
                                                          edit:Nil];
	emailSpecifier->action = @selector(hb_sendSupportEmail:);
	[emailSpecifier setProperty:NSClassFromString(@"HBLinkTableCell") forKey:@"cellClass"];
	[emailSpecifier setProperty:@"Send an email to me" forKey:@"subtitle"];
	[emailSpecifier setProperty:@YES forKey:@"enabled"];
	[emailSpecifier setProperty:@"fi.flodin.tonehelper" forKey:@"defaults"];
	//[emailSpecifier setProperty:NSStringFromSelector(@selector(hb_sendSupportEmail:)) forKey:@"action"];
	[emailSpecifier setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"email" ofType:@"png"]] forKey:@"iconImage"];

	[_specifiers addObject:githubSpecifier];
	[_specifiers addObject:redditSpecifier];
	[_specifiers addObject:emailSpecifier];
	[_specifiers addObject:donateSpecifier];
    return _specifiers;
}

- (void)respring:(PSSpecifier *)specifier {
	//ALog(@"Respring tapped");
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

- (void)hb_openURL:(PSSpecifier *)specifier {
	// get the url from the specifier
	NSURL *url = [NSURL URLWithString:specifier.properties[@"url"]];

	// if the url is nil, assert
	NSAssert(url, @"No URL was provided, or it is invalid.");

	// ensure SafariServices is loaded (if it exists)
	[[NSBundle bundleWithPath:@"/System/Library/Frameworks/SafariServices.framework"] load];

	// we can only use SFSafariViewController if it’s available (iOS 9), and the url scheme is http(s)
	if (%c(SFSafariViewController) && ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"])) {
		// initialise view controller
		SFSafariViewController *viewController = [[%c(SFSafariViewController) alloc] initWithURL:url];

		// use the same tint color as the presenting view controller
		viewController.view.tintColor = self.view.tintColor;

		// present it
		[self.realNavigationController presentViewController:viewController animated:YES completion:nil];
	} else {
		// just do a usual boring openURL:
		[[UIApplication sharedApplication] openURL:url];
	}
}

+ (nullable NSString *)hb_supportEmailAddress {
	return @"jesper@flodin.fi";
}

+ (nullable TSLinkInstruction *)hb_linkInstruction {
	if ([self hb_supportEmailAddress]) {
		return [HBSupportController linkInstructionForEmailAddress:[self hb_supportEmailAddress]];
	}

	return nil;
}

+ (nullable NSArray <TSIncludeInstruction *> *)hb_supportInstructions {
	NSMutableArray *includeInstructions = [NSMutableArray new];

    [includeInstructions addObject:[TSIncludeInstruction instructionWithString:@"include as \"ToneHelperData\" plist /var/mobile/Library/ToneHelper/ToneHelperData.plist"]];
	[includeInstructions addObject:[TSIncludeInstruction instructionWithString:@"include as \"Ringtones\" plist /var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist"]];
	//[includeInstructions addObject:[TSIncludeInstruction instructionWithString:@"include as \"logfile\" file /var/mobile/Library/ToneHelper/logfile.txt"]];

	//[includeInstructions addObject:[TSIncludeInstruction instructionWithString:@"include as \"File list AppSupport\" command /bin/ls -al /var/mobile/Library/"]];
	//[includeInstructions addObject:[TSIncludeInstruction instructionWithString:@"include as \"File list ToneHelperAppSupport\" command /bin/ls -al /var/mobile/Library/ToneHelper"]];
	[includeInstructions addObject:[TSIncludeInstruction instructionWithString:@"include as \"File list Ringtones\" command /bin/ls -al /var/mobile/Media/iTunes_Control/Ringtones"]];
	
	
	return includeInstructions;
}

- (void)hb_sendSupportEmail {
	//DLog(@"sendsupportemail called");
	[self hb_sendSupportEmail:nil];
}

- (void)hb_sendSupportEmail:(nullable PSSpecifier *)specifier {
	//DLog(@"sendsupportemail:specifier called");
	TSContactViewController *viewController = [HBSupportController supportViewControllerForBundle:[NSBundle bundleForClass:self.class] preferencesIdentifier:specifier.properties[@"defaults"] linkInstruction:[self.class hb_linkInstruction] supportInstructions:[self.class hb_supportInstructions]];

	if ([viewController respondsToSelector:@selector(tintColor)]) {
		viewController.view.tintColor = self.view.tintColor;
	}

	[self.realNavigationController pushViewController:viewController animated:YES];
}

@end
