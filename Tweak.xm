#import "JFTHHeaders.h"
#import "JFTHiOSHeaders.h"
#import "JFTHRingtoneImporter.h"

#import <version.h>

#pragma mark - Constants and preferences

BOOL kEnabled;
BOOL kDebugLogging;
BOOL kWriteITunesRingtonePlist;


extern NSString *const HBPreferencesDidChangeNotification;
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //We're in preferences app, lets look for new ringtones to import
        JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];
        
        //Apps to look for ringtones in (in Documents folder)
        NSMutableArray *apps = [[NSMutableArray alloc] init];
        [apps addObject:@"com.908.AudikoFree"];
        [apps addObject:@"com.zedge.Zedge"];
        [apps addObject:@"com.908.Audiko"];
        
        for (NSString *app in apps) {
            [importer getRingtoneFilesFromApp:app];
        }
        [apps release];
        
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

                    if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadTonesAfterExternalChange)])
                        [[%c(TLToneManager) sharedToneManager] _reloadTonesAfterExternalChange]; // IOS 11
                }
            });
        }
        [importer release];
    });
}

%end
#pragma mark - TLToneManager IOS 11
%hook TLToneManager

-(NSMutableArray *)_tonesFromManifestPath:(NSPathStore2 *)arg1 mediaDirectoryPath:(NSPathStore2 *)arg2 {
    DDLogVerbose(@"{\"Hooks\":\"TLToneManager bundleid=%@\"}",[[NSBundle mainBundle] bundleIdentifier]);
    if (!kEnabled || kWriteITunesRingtonePlist) {
        // kWriteITunesRingtonePlist enabled => disable runtime injection of ringtones
        DDLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection disabled\"}");
        return %orig;
    }
    DDLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection enabled\"}");
    
    if ([arg1 isEqualToString:RINGTONE_PLIST_PATH]) {
        //Save the ringtones array so we can modify it
        NSMutableArray *tones;
        if (!(tones = %orig)) {
            // got an empty object
            tones = [[NSMutableArray alloc] init];
        }
        
        DDLogVerbose(@"{\"Hooks\":\"TLToneManager got tones array: %@\"}",tones);
        
        //Read the ringtone metadata from our own plist
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];
        NSDictionary *importedTones = [toneData importedTones];

        for (NSString *file in importedTones) {
            // Create TLItunesTone object and put it into the array
            JFTHRingtone *curTone = [importedTones objectForKey:file];
            DDLogDebug(@"{\"Hooks\":\"TLToneManager created JFTHRingtone: %@\"}",curTone);
            
            TLITunesTone *tone = [[%c(TLITunesTone) alloc]
                                  initWithPropertyListRepresentation:[curTone iTunesPlistRepresentation]
                                                            filePath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:[curTone fileName]]];
            DDLogDebug(@"{\"Hooks\":\"TLToneManager created TLItunesTone: %@\"}",tone);
            
            [curTone release];
            [tones addObject:tone];
            [tone release];
        }
        
        [toneData release];
        [importedTones release];
        //Return the array with the ringtones the system found and the ringtones we have found
        DDLogInfo(@"{\"Hooks\":\"TLToneManager Read available ringtones\"}");
        return [tones autorelease];
    } else {
        // Not looking for the ringtones array we're interested in modifying
        DDLogVerbose(@"{\"Hooks\":\"TLToneManager Not reading ringtones\"}");
        return %orig;
    }
}
%end

%end

#pragma mark - IOS 10
//------- IOS 10 ---------
%group IOS10
#pragma mark - Preferences hook IOS 10
%hook PreferencesAppController
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        [self performSelector:@selector(doImportRingtones)];
    }
    return %orig;
}

- (void)applicationWillEnterForeground:(id)arg1 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
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
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //We're in preferences app, lets look for new ringtones to import
        JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];
        
        //Apps to look for ringtones in (in Documents folder)
        NSMutableArray *apps = [[NSMutableArray alloc] init];
        [apps addObject:@"com.908.AudikoFree"];
        [apps addObject:@"com.zedge.Zedge"];
        [apps addObject:@"com.908.Audiko"];
        
        for (NSString *app in apps) {
            [importer getRingtoneFilesFromApp:app];
        }
        [apps release];
        
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

                    if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadITunesRingtonesAfterExternalChange)])
                        [[%c(TLToneManager) sharedToneManager] _reloadITunesRingtonesAfterExternalChange]; // IOS 10
                }
            });
        }
        [importer release];
    });
}

%end
#pragma mark - TLToneManager IOS 10
%hook TLToneManager

-(id)_copyITunesRingtonesFromManifestPath:(id)arg1 mediaDirectoryPath:(id)arg2 {
    DDLogVerbose(@"{\"Hooks\":\"TLToneManager bundleid=%@\"}",[[NSBundle mainBundle] bundleIdentifier]);
    if (!kEnabled || kWriteITunesRingtonePlist) {
        // kWriteITunesRingtonePlist enabled => disable runtime injection of ringtones
        DDLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection disabled\"}");
        return %orig;
    }
    DDLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection enabled\"}");
    
    if ([arg1 isEqualToString:RINGTONE_PLIST_PATH]) {
        //Save the ringtones array so we can modify it
        NSMutableArray *tones;
        if (!(tones = %orig)) {
            // got an empty object
            tones = [[NSMutableArray alloc] init];
        }
        
        DDLogVerbose(@"{\"Hooks\":\"TLToneManager got tones array: %@\"}",tones);
        
        //Read the ringtone metadata from our own plist
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];
        NSDictionary *importedTones = [toneData importedTones];
        
        for (NSString *file in importedTones) {
            // Create TLItunesTone object and put it into the array
            JFTHRingtone *curTone = [importedTones objectForKey:file];
            DDLogDebug(@"{\"Hooks\":\"TLToneManager created JFTHRingtone: %@\"}",curTone);
            
            TLITunesTone *tone = [[%c(TLITunesTone) alloc]
                                  initWithPropertyListRepresentation:[curTone iTunesPlistRepresentation]
                                  filePath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:[curTone fileName]]];
            DDLogDebug(@"{\"Hooks\":\"TLToneManager created TLItunesTone: %@\"}",tone);
            
            [curTone release];
            [tones addObject:tone];
            [tone release];
        }
        
        [toneData release];
        [importedTones release];
        //Return the array with the ringtones the system found and the ringtones we have found
        DDLogInfo(@"{\"Hooks\":\"TLToneManager Read available ringtones\"}");
        return [tones autorelease];
    } else {
        // Not looking for the ringtones array we're interested in modifying
        DDLogVerbose(@"{\"Hooks\":\"TLToneManager Not reading ringtones\"}");
        return %orig;
    }
}
%end

%end


HBPreferencesValueChangeCallback updateRingtonePlist = ^(NSString *key, id<NSCopying> _Nullable newValue) {
    
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"] ||
        [[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
        // only run in springboard or preferences
        
        BOOL value = [[(NSNumber *)newValue copy] boolValue];
        DDLogDebug(@"{\"Preferences\":\"Notification received for key:%@ with value:%d\"}",key,value);

        if ([key isEqualToString:@"kWriteITunesRingtonePlist"]) {

            [[[JFTHRingtoneDataController alloc] init] syncPlists:value];
        }
    }
};


#pragma mark - Constructor
//------------- Constructor ------------
%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"{\"Constructor\":\"Loaded in bundle: %@\"}", bundleID);
    
    if ([bundleID isEqualToString:@"com.apple.TelephonyUtilities"] ||
        [bundleID isEqualToString:@"com.apple.InCallService"] ||
        [bundleID isEqualToString:@"com.apple.Preferences"] ||
        [bundleID isEqualToString:@"com.apple.mobilephone"] ||
        [bundleID isEqualToString:@"com.apple.springboard"] ||
        [bundleID isEqualToString:@"com.apple.MobileSMS"] ||
        [bundleID isEqualToString:@"com.apple.mobilemail"] ||
        [bundleID isEqualToString:@"com.apple.mobiletimer"] ||
        [bundleID isEqualToString:@"nanomediaremotelinkagent"]) {

        [bundleID release];
        
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];

        if (kDebugLogging) {
            
            LogglyFields *logglyFields = [[LogglyFields alloc] init];
            [logglyFields setAppversion:@"0.4.0"];
            
            [logglyFields setUserid:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            
            LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
            [logglyLogger setLogFormatter:[[LogglyFormatter alloc] initWithLogglyFieldsDelegate:logglyFields]];
            
            
            logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
            
            logglyLogger.saveInterval = 600;
            
            [DDLog addLogger:logglyLogger];
            [logglyFields release];
            [logglyLogger release];
            [DDLog addLogger:[DDASLLogger sharedInstance]];
        }
        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        [preferences registerPreferenceChangeBlock:(HBPreferencesValueChangeCallback)updateRingtonePlist forKey:@"kWriteITunesRingtonePlist"];
        
        DDLogInfo(@"{\"Constructor\":\"Trying to initialize ToneHelper in bundleid: %@\"}",[[NSBundle mainBundle] bundleIdentifier]);
        if (!NSClassFromString(@"TLToneManager")) {
            DDLogInfo(@"{\"Constructor\":\"TLToneManager missing, loading framework\"}");
            dlopen("/System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary", RTLD_LAZY);
        }
        /*if (!NSClassFromString(@"TKTonePickerController")) {
            DDLogInfo(@"Loading ToneKit");
            dlopen("/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit", RTLD_LAZY);
        }*/
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
            DDLogInfo(@"{\"Constructor\":\"Init IOS 11\"}");
            %init(IOS11);
        } else {
            DDLogInfo(@"{\"Constructor\":\"Init IOS 10\"}");
            %init(IOS10);
        }

    }
}
