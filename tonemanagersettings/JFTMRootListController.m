#include "JFTMRootListController.h"

@implementation JFTMRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

-(void)openAppButton {
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tonemanager:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tonemanager://"]];
}

-(void)resetButton {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary * defaultSettings = @{
                            @"AutoInstall":@YES,
                            @"RemoteLogging":@YES,
                            @"AudikoLite":@YES,
                            @"AudikoPro":@YES,
                            @"ZedgeRingtones":@YES,
                            @"ExtraApps":@[],
                            @"Version":@"0.5.0",
                            @"Build":@"1",
                            @"FirstRun":@YES,
                            @"IsUpdated":@NO,
                            @"ScanRecursively":@NO
                            };
    for (NSString *key in defaultSettings) {
        [userDefaults setObject:defaultSettings[key] forKey:key];
    }
    [userDefaults synchronize];
}

-(void)twitterButton {
    NSString *user = @"JesperFlodin";
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:user]]];
    
    else if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]])
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:user]]];
    
    else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:user]]];
    
}


@end
