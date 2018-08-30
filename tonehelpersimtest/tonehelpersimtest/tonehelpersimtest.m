//
//  tonehelpersimtest.m
//  tonehelpersimtest
//
//  Created by Jesper Flodin on 2018-08-27.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JFTHCommonHeaders.h"
#import "JFTHiOSHeaders.h"
#import "JFTHRingtoneImporter.h"
#import "JFTHRingtoneDataController.h"
#import "JFTHRingtone.h"
#import "JFTHConstants.h"


#import <version.h>

BOOL kEnabled;
BOOL kDebugLogging;

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];
        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        
        

        //[DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor yellowColor] backgroundColor:nil forFlag:DDLogFlagInfo];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagDebug];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor lightGrayColor] backgroundColor:nil forFlag:DDLogFlagVerbose];

        DDLogWarn(@"kDebugLogging=%d kEnabled=%d kWriteITunesRingtonePlist=%d bundle=%@",kDebugLogging,kEnabled,kWriteITunesRingtonePlist,[[NSBundle mainBundle] bundleIdentifier]);
        
        //[preferences setBool:YES forKey:@"kEnabled"];
        
        DDLogWarn(@"enabled=%d home=%@",kEnabled,NSHomeDirectory());
        
        NSString *debugBundle = @"fi.flodin.tonehelperdebugging";
        
        
    }
    return 0;
}
