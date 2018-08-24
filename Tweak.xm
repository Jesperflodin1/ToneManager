#import "JFTHHeaders.h"

#import "JFTHRingtoneImporter.h"


NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

BOOL kEnabled;
BOOL kDebugLogging;
BOOL kWriteITunesRingtonePlist;


extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;


%group IOS11

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
    NSLog(@" JFDEBUG starting");
    DDLogDebug(@"In preferences");
    if (!kEnabled) {
        DDLogDebug(@"Disabled");
        return;
    }
    DDLogInfo(@"Enabled");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
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
            //Found something new to import?
            if ([importer shouldImportRingtones]) {
                [importer importNewRingtones];
            }
            // imported something?
            if ([importer importedCount] > 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    DDLogDebug(@"trying to reload tones");
                    
                    if (NSClassFromString(@"TLToneManager")) {
                        
                        DDLogDebug(@"TLTonemanager loaded, reloading tones");
                        // _reloadTonesAfterExternalChange IOS 11 only
                        if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadTonesAfterExternalChange)])
                            [[%c(TLToneManager) sharedToneManager] _reloadTonesAfterExternalChange]; // IOS 11
                        
                        else if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadITunesRingtonesAfterExternalChange)])
                            [[%c(TLToneManager) sharedToneManager] _reloadITunesRingtonesAfterExternalChange]; // IOS 10
                    }
                    //[[self valueForKey:@"_tonePickerController"] _reloadMediaItems];
                });
            }
        }
    });
}

%end

%hook TLToneManager

/*
-(id)_copyITunesRingtonesFromManifestPath:(id)arg1 mediaDirectoryPath:(id)arg2 {
    UIAlertView *lookWhatWorks = [[UIAlertView alloc]
                                    initWithTitle:@"simject Example Tweak"
                                            message:@"ctor"
                                            delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
        [lookWhatWorks show];
    return %orig;
}*/

-(NSMutableArray *)_tonesFromManifestPath:(NSPathStore2 *)arg1 mediaDirectoryPath:(NSPathStore2 *)arg2 {
    @autoreleasepool {
        if (!kEnabled || kWriteITunesRingtonePlist) {
            // kWriteITunesRingtonePlist enabled => disable runtime injection of ringtones
            DDLogInfo(@"Disabled");
            return %orig;
        }
        DDLogInfo(@"Enabled");
        if ([arg1 isEqualToString:RINGTONE_PLIST_PATH]) {
            //Save the ringtones array so we can modify it
            NSMutableArray *tones = %orig;

            //Read the ringtone metadata from our own plist
            JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];
            NSDictionary *importedTones = [toneData getImportedRingtones];

            for (NSString *file in importedTones) {
                // Create TLItunesTone object and put it into the array

                TLITunesTone *tone = [[%c(TLITunesTone) alloc] initWithPropertyListRepresentation:@{
                    @"GUID": [[importedTones objectForKey:file] objectForKey:@"GUID"],
                    @"Name": [[importedTones objectForKey:file] objectForKey:@"Name"],
                    @"PID": [[importedTones objectForKey:file] objectForKey:@"PID"],
                    @"Protected Content" : @NO

                } filePath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:file]];
                
                [tones addObject:tone];
            }
            //Return the array with the ringtones the system found and the ringtones we have found
            DDLogInfo(@"Read available ringtones");
            return tones;
        } else {
            // Not looking for the ringtones array we're interested in modifying
            DDLogVerbose(@"Not reading ringtones");
            return %orig;
        }
    }
}
%end

%end


%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if ([bundleID isEqualToString:@"com.apple.Preferences"] ||
        [bundleID isEqualToString:@"com.apple.springboard"] ||
        [bundleID isEqualToString:@"com.apple.InCallService"] ||
        [bundleID isEqualToString:@"com.apple.MobileSMS"] ||
        [bundleID isEqualToString:@"com.apple.mobilephone"] ||
        [bundleID isEqualToString:@"com.apple.MobileAddressBook"] ||
        [bundleID isEqualToString:@"com.apple.mobilemail"] ||
        [bundleID isEqualToString:@"com.apple.mobiletimer"] ||
        [bundleID isEqualToString:@"com.apple.ToneLibrary"]) {
        
        HBPreferencesValueChangeCallback updateRingtonePlist = ^(NSString *key, id<NSCopying> _Nullable newValue) {
            BOOL value = [[(NSNumber *)newValue copy] boolValue];
            DDLogDebug(@"Notification received for key:%@ with value:%d",key,value);
            if ([key isEqualToString:@"kWriteITunesRingtonePlist"]) {
                [JFTHRingtoneDataController syncPlists:value];
            }
        };
        
        
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];

        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        [preferences registerPreferenceChangeBlock:(HBPreferencesValueChangeCallback)updateRingtonePlist forKey:@"kWriteITunesRingtonePlist"];
        
        [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];
        if (kDebugLogging) {
            LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
            [logglyLogger setLogFormatter:[[LogglyFormatter alloc] init]];
            logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
            
            // Set posting interval every 15 seconds, just for testing this out, but the default value of 600 seconds is better in apps
            // that normally don't access the network very often. When the user suspends the app, the logs will always be posted.
            logglyLogger.saveInterval = 600;
            
            [DDLog addLogger:logglyLogger];
        }
        DDLogInfo(@"Trying to initialize ToneHelper in bundleid: %@",[[NSBundle mainBundle] bundleIdentifier]);
        if (!NSClassFromString(@"TLToneManager")) {
            DDLogDebug(@"TLToneManager missing, loading framework");
            dlopen("/System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary", RTLD_LAZY);
        }
        if (!NSClassFromString(@"TKTonePickerController")) {
            DDLogDebug(@"Loading ToneKit");
            dlopen("/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit", RTLD_LAZY);
        }

        //if () {
        %init(IOS11);
        //}
    }
    
}
