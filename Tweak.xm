#import "JFTHCommonHeaders.h"
#import "JFTHiOSHeaders.h"
#import "JFTHRingtoneScanner.h"

#import <version.h>
// TODO: Add ringtone maker (or applist)

#import <Foundation/NSDistributedNotificationCenter.h>
#pragma mark - Constants and preferences

BOOL kTHEnabled;
BOOL kTHDebugLogging;
HBPreferences *preferences;

/*%group SpringboardHook

%hook SpringBoard
-(void)applicationDidFinishLaunching:(id)application {
    %orig;
    
    [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"fi.flodin.tonehelper/importAll" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
        NSLog(@"Received importAll message, calling ringtone import"); //, [notification.userInfo objectForKey:@"id"], [notification.userInfo objectForKey:@"type"]);
        [self performSelector:(@selector(importAllRingtones))];
    }];
}

%new
- (void)importAllRingtones {
    if (!kTHEnabled) {
        DDLogInfo(@"{\"Hooks\":\"importAll called, Disabled\"}");
        return;
    }
    DDLogInfo(@"{\"Hooks\":\"importAll called, Enabled\"}");
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JFTHRingtoneScanner *scanner = [JFTHRingtoneScanner new];
        
        //Apps to look for ringtones in (in Documents folder)
        NSDictionary *apps = @{
                        @"com.908.AudikoFree":@"Documents",
                        @"com.zedge.Zedge":@"Documents",
                        @"com.908.Audiko":@"Documents"
                        };
        
        [scanner importNewRingtonesFromSubfoldersInApps:apps];
        [apps release];
        [scanner release];
    //});
}

%end
%end*/

%group AudikoLiteHook
%hook AppDelegate

- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    DDLogVerbose(@"{\"Hooks\":\"didFinishLaunching called, registering for notifications\"}");
    /*UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(importAllRingtones)
                                                 name:UIApplicationWillTerminateNotification
                                               object:app];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(importAllRingtones)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:app];
    [app release];*/
    [self performSelector:@selector(importAllRingtones)];
}

%new
- (void)importAllRingtones {
    if (!kTHEnabled) {
        DDLogInfo(@"{\"Hooks\":\"importAll called, Disabled\"}");
        return;
    }
    DDLogInfo(@"{\"Hooks\":\"importAll called, Enabled\"}");
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    JFTHRingtoneScanner *scanner = [JFTHRingtoneScanner new];
    
    //Apps to look for ringtones in (in Documents folder)
    NSDictionary *apps = @{
                           @"com.908.AudikoFree":@"Documents"
                           };
    
    [scanner importNewRingtonesFromSubfoldersInApps:apps];
    [apps release];
    [scanner release];
    //});
}

%end
%end
/*%group PreferencesHook

#pragma mark - Preferences hook IOS 11
%hook PreferencesAppController
 - (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
     if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
         DDLogVerbose(@"{\"Hooks\":\"didFinishLaunching called\"}");
         
         /*NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
         [userInfo setObject:[NSBundle mainBundle].bundleIdentifier forKey:@"id"];
         [userInfo setObject:@"Preferences" forKey:@"type"];*/
         //[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"fi.flodin.tonehelper/importAll" object:nil userInfo:nil];
         //[userInfo release];
/*     }
     return %orig;
 }
 
 - (void)applicationWillEnterForeground:(id)arg1 {
     if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
         DDLogVerbose(@"{\"Hooks\":\"applicationWillEnterForeground called\"}");
         
         /*NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
         [userInfo setObject:[NSBundle mainBundle].bundleIdentifier forKey:@"id"];
         [userInfo setObject:@"Preferences" forKey:@"type"];*/
         //[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"fi.flodin.tonehelper/importAll" object:nil userInfo:nil];
         //[userInfo release];
    /* }
     return %orig;
 }

%end
%end*/

static void initTHLogging () {
    LogglyFields *logglyFields = [[LogglyFields alloc] init];
    [logglyFields setAppversion:@"0.4.2"];
    
    [logglyFields setUserid:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
     
     LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
     [logglyLogger setLogFormatter:[[LogglyFormatter alloc] initWithLogglyFieldsDelegate:logglyFields]];
     logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
     
     logglyLogger.saveInterval = 600;
     
     [DDLog addLogger:logglyLogger];
     [DDLog addLogger:[DDASLLogger sharedInstance]];
     [logglyFields release];
     [logglyLogger release];
}
     
static void initTHPrefs () {
     preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
     [preferences registerBool:&kTHDebugLogging default:NO forKey:@"kDebugLogging"];
     [preferences registerBool:&kTHEnabled default:NO forKey:@"kEnabled"];
     
     [preferences release];
}

extern NSString *const HBPreferencesDidChangeNotification;

#pragma mark - Constructor
//------------- Constructor ------------
%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    /*if ([bundleID isEqualToString:@"com.apple.springboard"]) {
        
        initTHPrefs();
        //if (kTHDebugLogging) {
            initTHLogging();
        //}
        DDLogInfo(@"{\"Constructor\":\"Loaded in bundle: %@\"}", bundleID);
        [bundleID release];

        %init(SpringboardHook);
        /*if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
            DDLogInfo(@"{\"Constructor\":\"Init IOS 11\"}");
            %init(IOS11);
        } else {
            DDLogInfo(@"{\"Constructor\":\"Init IOS 10\"}");
            %init(IOS10);
        }*/

    /*} else if ([bundleID isEqualToString:@"com.apple.Preferences"]) {
        initTHPrefs();
        //if (kTHDebugLogging) {
        initTHLogging();
        //}
        DDLogInfo(@"{\"Constructor\":\"Loaded in bundle: %@\"}", bundleID);
        [bundleID release];
        
        %init(PreferencesHook);
        
    }*/
    if ([bundleID isEqualToString:@"com.908.AudikoFree"]) {
        
        initTHPrefs();
        //if (kTHDebugLogging) {
        initTHLogging();
        //}
        DDLogInfo(@"{\"Constructor\":\"Loaded in bundle: %@\"}", bundleID);
        [bundleID release];
        
        %init(AudikoLiteHook);
    }
    
}
