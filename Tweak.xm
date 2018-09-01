#import "JFTHCommonHeaders.h"
#import "JFTHiOSHeaders.h"
#import "JFTHRingtoneScanner.h"

#import <version.h>
// TODO: Add ringtone maker (or applist)
#pragma mark - Constants and preferences

BOOL kEnabled;
BOOL kDebugLogging;
HBPreferences *preferences;


#pragma mark - IOS 11
// -------- IOS 11 ---------
%group IOS11

#pragma mark - Preferences hook IOS 11
%hook PreferencesAppController
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        DDLogVerbose(@"{\"Hooks\":\"didFinishLaunching called\"}");
        [self performSelector:@selector(doImportRingtones)];
    }
    return %orig;
}

- (void)applicationWillEnterForeground:(id)arg1 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        DDLogVerbose(@"{\"Hooks\":\"applicationWillEnterForeground called\"}");
        [self performSelector:@selector(doImportRingtones)];
    }
    return %orig;
}

%new
- (void)doImportRingtones {
    DDLogInfo(@"{\"Hooks\":\"In preferences\"}");
    if (!kEnabled) {
        DDLogInfo(@"{\"Hooks\":\"in preferences, Disabled\"}");
        return;
    }
    DDLogInfo(@"{\"Hooks\":\"in preferences, Enabled\"}");
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //We're in preferences app, lets look for new ringtones to import
        JFTHRingtoneScanner *scanner = [JFTHRingtoneImporter new];
        
        //Apps to look for ringtones in (in Documents folder)
        NSDictionary *apps = @[
                        @"com.908.AudikoFree":@"Documents",
                        @"com.zedge.Zedge":@"Documents",
                        @"com.908.Audiko":@"Documents"
                        ];
        
        [scanner importNewRingtonesFromSubfoldersInApps:apps];
        [apps release];
 
        // imported something?
        /*if ([importer importedCount] > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                DDLogDebug(@"{\"Hooks\":\"in preferences background thread, trying to reload tones\"}");
                
                if (NSClassFromString(@"TLToneManager")) {
                    
                    DDLogDebug(@"{\"Hooks\":\"in preferences background thread, TLTonemanager loaded, reloading tones\"}");

                    if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadTonesAfterExternalChange)])
                        [[%c(TLToneManager) sharedToneManager] _reloadTonesAfterExternalChange]; // IOS 11
                }
            });
        }*/
        [scanner release];
    //});
}

%end
%end

extern NSString *const HBPreferencesDidChangeNotification;

#pragma mark - Constructor
//------------- Constructor ------------
%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"{\"Constructor\":\"Loaded in bundle: %@\"}", bundleID);
    
    if ([bundleID isEqualToString:@"com.apple.Preferences"]) {

        [bundleID release];
        
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];
        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];


        //if (kDebugLogging) {
            LogglyFields *logglyFields = [[LogglyFields alloc] init];
            [logglyFields setAppversion:@"0.4.0"];
            
            [logglyFields setUserid:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            
            LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
            [logglyLogger setLogFormatter:[[LogglyFormatter alloc] initWithLogglyFieldsDelegate:logglyFields]];
            logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
            
            logglyLogger.saveInterval = 600;
            
            [DDLog addLogger:logglyLogger];
            [DDLog addLogger:[DDASLLogger sharedInstance]];
            [logglyFields release];
            [logglyLogger release];
        //}
        
        [preferences release];
        
        DDLogInfo(@"{\"Constructor\":\"Trying to initialize ToneHelper in bundleid: %@\"}",[[NSBundle mainBundle] bundleIdentifier]);
        if (!NSClassFromString(@"TLToneManager")) {
            DDLogInfo(@"{\"Constructor\":\"TLToneManager missing, loading framework\"}");
            dlopen("/System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary", RTLD_LAZY);
        }
        %init(IOS11);
        /*if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
            DDLogInfo(@"{\"Constructor\":\"Init IOS 11\"}");
            %init(IOS11);
        } else {
            DDLogInfo(@"{\"Constructor\":\"Init IOS 10\"}");
            %init(IOS10);
        }*/

    }
}
