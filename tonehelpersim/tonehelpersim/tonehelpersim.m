//
//  tonehelpersim.m
//  tonehelpersim
//
//  Created by Jesper Flodin on 2018-08-29.
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
        
        HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];
        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
        

        
        
        
        //[DDLog addLogger:[DDASLLogger sharedInstance]];
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
        [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
        
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor yellowColor] backgroundColor:nil forFlag:DDLogFlagInfo];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor greenColor] backgroundColor:nil forFlag:DDLogFlagDebug];
        [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor lightGrayColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
        
        DDLogWarn(@"kDebugLogging=%d kEnabled=%d bundle=%@",kDebugLogging,kEnabled,[[NSBundle mainBundle] bundleIdentifier]);
        
        [preferences setBool:YES forKey:@"kDebugLogging"];
        [preferences setBool:YES forKey:@"kEnabled"];
        
        DDLogWarn(@"enabled=%d home=%@",kEnabled,NSHomeDirectory());
        
        // -------- doImport() ---------
        DDLogInfo(@"{\"Hooks\":\"In preferences\"}");
        if (!kEnabled) {
            DDLogInfo(@"{\"Hooks\":\"in preferences, Disabled\"}");
            return 0;
        }
        DDLogInfo(@"{\"Hooks\":\"in preferences, Enabled\"}");
        //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            //We're in preferences app, lets look for new ringtones to import
            JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];
            
            //Apps to look for ringtones in (in Documents folder)
            NSArray *apps = @[ @"com.908.AudikoFree", @"com.908.Audiko", @"com.zedge.Zedge", @"fi.flodin.tonehelperdebugging"];
            
            for (NSString *app in apps) {
                [importer getRingtoneFilesFromApp:app];
            }
            //[apps release];
            
            //Found something new to import?
            if ([importer shouldImportRingtones]) {
                [importer importNewRingtones];
            }
            // imported something?
            if ([importer importedCount] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DDLogDebug(@"{\"Hooks\":\"in preferences background thread, trying to reload tones\"}");
                    
                    if (NSClassFromString(@"TLToneManager")) {
                        
                        DDLogDebug(@"{\"Hooks\":\"in preferences background thread, TLTonemanager loaded, reloading tones\"}");
                        
                        /*if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadTonesAfterExternalChange)])
                         [[%c(TLToneManager) sharedToneManager] _reloadTonesAfterExternalChange];*/ // IOS 11
                    }
                });
            }
            //[importer release];
        //});
    }
    return 0;
}
