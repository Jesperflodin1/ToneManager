#import "JFTHHeaders.h"
#import "JFTHiOSHeaders.h"
#import "JFTHRingtoneImporter.h"

#import <version.h>

#import "TLAlertConfiguration.h"
#import "TLAlert.h"


#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d JFDEBUG] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#pragma mark - Constants and preferences

BOOL kEnabled;
BOOL kDebugLogging;
BOOL kWriteITunesRingtonePlist;



HBPreferences *preferences;


#pragma mark - IOS 11
// -------- IOS 11 ---------
%group IOS11
/*
#pragma mark - Preferences hook IOS 11
%hook PreferencesAppController
- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        DLogVerbose(@"{\"Hooks\":\"didFinishLaunching called\"}");
        [self performSelector:@selector(doImportRingtones)];
    }
    return %orig;
}

- (void)applicationWillEnterForeground:(id)arg1 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        DLogVerbose(@"{\"Hooks\":\"applicationWillEnterForeground called\"}");
        [self performSelector:@selector(doImportRingtones)];
    }
    return %orig;
}

%new
- (void)doImportRingtones {
    DLogInfo(@"{\"Hooks\":\"In preferences\"}");
    if (!kEnabled) {
        DLogInfo(@"{\"Hooks\":\"in preferences, Disabled\"}");
        return;
    }
    DLogInfo(@"{\"Hooks\":\"in preferences, Enabled\"}");
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
                DLogDebug(@"{\"Hooks\":\"in preferences background thread, trying to reload tones\"}");
                
                if (NSClassFromString(@"TLToneManager")) {
                    
                    DLogDebug(@"{\"Hooks\":\"in preferences background thread, TLTonemanager loaded, reloading tones\"}");

                    if ([[%c(TLToneManager) sharedToneManager] respondsToSelector:@selector(_reloadTonesAfterExternalChange)])
                        [[%c(TLToneManager) sharedToneManager] _reloadTonesAfterExternalChange]; // IOS 11
                }
            });
        }
        [importer release];
    });
}

%end*/
#pragma mark - TLToneManager IOS 11
%hook TLToneManager

-(NSMutableArray *)_tonesFromManifestPath:(NSPathStore2 *)arg1 mediaDirectoryPath:(NSPathStore2 *)arg2 {
    DLog(@"{\"Hooks\":\"TLToneManager bundleid=%@\"}",[[NSBundle mainBundle] bundleIdentifier]);
    NSMutableArray *org = %orig;
    DLog(@"_tonesFromManifestPath orig=%@",org);
    return org;
    /*if (!kEnabled || kWriteITunesRingtonePlist) {
        // kWriteITunesRingtonePlist enabled => disable runtime injection of ringtones
        DLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection disabled\"}");
        return %orig;
    }
    DLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection enabled\"}");
    
    if ([arg1 isEqualToString:RINGTONE_PLIST_PATH]) {
        //Save the ringtones array so we can modify it
        NSMutableArray *tones;
        if (!(tones = %orig)) {
            // got an empty object
            tones = [[NSMutableArray alloc] init];
        }
        
        DLogVerbose(@"{\"Hooks\":\"TLToneManager got tones array: %@\"}",tones);
        
        //Read the ringtone metadata from our own plist
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];
        NSDictionary *importedTones = [toneData importedTones];

        for (NSString *file in importedTones) {
            // Create TLItunesTone object and put it into the array
            JFTHRingtone *curTone = [importedTones objectForKey:file];
            DLogDebug(@"{\"Hooks\":\"TLToneManager created JFTHRingtone: %@\"}",curTone);
            
            TLITunesTone *tone = [[%c(TLITunesTone) alloc]
                                  initWithPropertyListRepresentation:[curTone iTunesPlistRepresentation]
                                                            filePath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:[curTone fileName]]];
            DLogDebug(@"{\"Hooks\":\"TLToneManager created TLItunesTone: %@\"}",tone);
            
            [curTone release];
            [tones addObject:tone];
            [tone release];
        }
        
        [toneData release];
        [importedTones release];
        //Return the array with the ringtones the system found and the ringtones we have found
        DLogInfo(@"{\"Hooks\":\"TLToneManager Read available ringtones\"}");
        return [tones autorelease];
    } else {
        // Not looking for the ringtones array we're interested in modifying
        DLogVerbose(@"{\"Hooks\":\"TLToneManager Not reading ringtones\"}");
        return %orig;
    }*/
}
%end

%hook TLAlert
- (void)setPlaybackObserver:(id<TLAlertPlaybackObserver> )playbackObserver { DLog(@"playbackobserver=%@",playbackObserver); %orig; }

- (id<TLAlertPlaybackObserver> )playbackObserver { id<TLAlertPlaybackObserver>  r = %orig; DLog(@" = %@",r); return r; }

- (TLAlertConfiguration * )configuration { TLAlertConfiguration *  r = %orig; DLog(@" = %@", r); return r; }

- (long long )type { long long  r = %orig; DLog(@" = %lld", r); return r; }
- (NSString * )toneIdentifier { NSString *  r = %orig; DLog(@" = %@", r); return r; }
- (NSString * )vibrationIdentifier { NSString *  r = %orig; DLog(@" = %@", r); return r; }

+(void)playAlertForType:(long long)arg1  { DLog(@"arg1=%lld",arg1); %orig; }
+(void)playToneAndVibrationForType:(long long)arg1  { DLog(@"arg1=%lld",arg1); %orig; }

+(BOOL)_watchPrefersSalientToneAndVibration { BOOL r = %orig; DLog(@" = %d", r); return r; }

+(void)_setWatchPrefersSalientToneAndVibration:(BOOL)arg1  { DLog(@"arg1=%d",arg1); %orig; }

+(BOOL)_stopAllAlerts { BOOL r = %orig; DLog(@" = %d", r); return r; }

+(id)alertWithConfiguration:(id)arg1  { DLog(@"arg1=%@",arg1); id r = %orig; DLog(@" = %@", r); return r; }

-(id)description { id r = %orig; DLog(@" = %@", r); return r; }
-(id)debugDescription { id r = %orig; DLog(@" = %@", r); return r; }

-(id)initWithType:(long long)arg1  { DLog(@"arg1=%lld",arg1); id r = %orig; DLog(@" = %@", r); return r; }
-(void)stop { DLog(@"stop"); %orig; }
-(void)play { DLog(@"play"); %orig; }

-(id)initWithType:(long long)arg1 accountIdentifier:(id)arg2  { DLog(@"arg1=%lld arg2=%@",arg1,arg2); id r = %orig; DLog(@" = %@", r); return r; }

-(id)_initWithConfiguration:(id)arg1 toneIdentifier:(id)arg2 vibrationIdentifier:(id)arg3  { DLog(@"arg1=%@ arg2=%@ arg3=%@",arg1,arg2,arg3); id r = %orig; DLog(@" = %@", r); return r; }

-(id)_descriptionForDebugging:(BOOL)arg1  { DLog(@"arg1=%d",arg1); id r = %orig; DLog(@" = %@", r); return r; }
-(id)initWithType:(long long)arg1 toneIdentifier:(id)arg2 vibrationIdentifier:(id)arg3  { DLog(@"arg1=%lld arg2=%@ arg3=%@",arg1,arg2,arg3); id r = %orig; DLog(@" = %@", r); return r; }

-(void)stopWithOptions:(id)arg1  { DLog(@"arg1=%@",arg1); %orig; }

%end

%hook TLAlertConfiguration
- (NSString * )topic { NSString *  r = %orig; DLog(@" = %@", r); return r; }

- (void)setToneIdentifier:(NSString * )toneIdentifier { DLog(@"toneidentifier=%@",toneIdentifier); %orig; }

- (NSString * )toneIdentifier { NSString *  r = %orig; DLog(@" = %@", r); return r; }

- (void)setVibrationIdentifier:(NSString * )vibrationIdentifier { DLog(@"vibrationIdentifier=%@",vibrationIdentifier); %orig; }

- (NSString * )vibrationIdentifier { NSString *  r = %orig; DLog(@" = %@", r); return r; }
- (NSURL * )externalToneFileURL { NSURL *  r = %orig; DLog(@" = %@", r); return r; }

- (void)setExternalToneMediaLibraryItemIdentifier:(unsigned long long )externalToneMediaLibraryItemIdentifier { DLog(@"externalToneMediaLibraryItemIdentifier=%llu",externalToneMediaLibraryItemIdentifier); %orig; }

- (unsigned long long )externalToneMediaLibraryItemIdentifier { unsigned long long  r = %orig; DLog(@" = %llu", r); return r; }

- (void)setExternalVibrationPattern:(NSDictionary * )externalVibrationPattern { DLog(@"externalVibrationPattern=%@",externalVibrationPattern); %orig; }

- (NSDictionary * )externalVibrationPattern { NSDictionary *  r = %orig; DLog(@" = %@", r); return r; }

- (void)setExternalVibrationPatternFileURL:(NSURL * )externalVibrationPatternFileURL { DLog(@"externalVibrationPatternFileURL=%@",externalVibrationPatternFileURL); %orig; }

- (NSURL * )externalVibrationPatternFileURL { NSURL *  r = %orig; DLog(@" = %@", r); return r; }

- (void)setAudioCategory:(NSString * )audioCategory { DLog(@"audioCategory=%@",audioCategory); %orig; }

- (NSString * )audioCategory { NSString *  r = %orig; DLog(@" = %@", r); return r; }

- (void)setAudioVolume:(float )audioVolume { DLog(@"audioVolume=%f",audioVolume); %orig; }

- (float )audioVolume { float  r = %orig; DLog(@" = %f", r); return r; }

- (void)setForPreview:(BOOL )forPreview { DLog(@"forPreview=%d",forPreview); %orig; }

- (BOOL )isForPreview { BOOL  r = %orig; DLog(@" = %d", r); return r; }

- (void)setShouldRepeat:(BOOL )shouldRepeat { DLog(@"shouldRepeat=%d",shouldRepeat); %orig; }

- (BOOL )shouldRepeat { BOOL  r = %orig; DLog(@" = %d", r); return r; }

+(BOOL)supportsSecureCoding { BOOL r = %orig; DLog(@" = %d", r); return r; }

-(id)initWithCoder:(id)arg1  { DLog(@"arg1=%@",arg1); id r = %orig; DLog(@" = %@", r); return r; }

-(void)encodeWithCoder:(id)arg1  { DLog(@"arg1=%@",arg1); %orig; }

-(BOOL)isEqual:(id)arg1  { DLog(@"arg1=%@",arg1); BOOL r = %orig; DLog(@" = %d", r); return r; }

-(unsigned long long)hash { unsigned long long r = %orig; DLog(@" = %llu", r); return r; }

-(id)description { id r = %orig; DLog(@" = %@", r); return r; }
-(long long)type { long long r = %orig; DLog(@" = %lld", r); return r; }

-(id)copyWithZone:(NSZone*)arg1  { DLog(@"arg1=%@",arg1); id r = %orig; DLog(@" = %@", r); return r; }

-(id)initWithType:(long long)arg1  { DLog(@"arg1=%lld",arg1); id r = %orig; DLog(@" = %@", r); return r; }

-(void)setMaximumDuration:(double)arg1  { DLog(@"arg1=%f",arg1); %orig; }

-(void)setShouldIgnoreRingerSwitch:(BOOL)arg1  { DLog(@"arg1=%d",arg1); %orig; }
-(BOOL)shouldIgnoreRingerSwitch { BOOL r = %orig; DLog(@" = %d", r); return r; }

-(void)setTopic:(NSString *)arg1  { DLog(@"arg1=%@",arg1); %orig; }

-(void)setExternalToneFileURL:(NSURL *)arg1  { DLog(@"arg1=%@",arg1); %orig; }


%end

%end

#pragma mark - IOS 10
//------- IOS 10 ---------
%group IOS10
#pragma mark - Preferences hook IOS 10
%hook PreferencesAppController
/*- (_Bool)application:(id)arg1 didFinishLaunchingWithOptions:(id)arg2 {
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
    DLogInfo(@"{\"Hooks\":\"In preferences\"}");
    if (!kEnabled) {
        DLogInfo(@"{\"Hooks\":\"in preferences, Disabled\"}");
        return;
    }
    DLogInfo(@"{\"Hooks\":\"in preferences, Enabled\"}");
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
                DLogDebug(@"{\"Hooks\":\"in preferences background thread, trying to reload tones\"}");
                
                if (NSClassFromString(@"TLToneManager")) {
                    
                    DLogDebug(@"{\"Hooks\":\"in preferences background thread, TLTonemanager loaded, reloading tones\"}");

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
    DLogVerbose(@"{\"Hooks\":\"TLToneManager bundleid=%@\"}",[[NSBundle mainBundle] bundleIdentifier]);
    if (!kEnabled || kWriteITunesRingtonePlist) {
        // kWriteITunesRingtonePlist enabled => disable runtime injection of ringtones
        DLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection disabled\"}");
        return %orig;
    }
    DLogInfo(@"{\"Hooks\":\"TLToneManager runtime injection enabled\"}");
    
    if ([arg1 isEqualToString:RINGTONE_PLIST_PATH]) {
        //Save the ringtones array so we can modify it
        NSMutableArray *tones;
        if (!(tones = %orig)) {
            // got an empty object
            tones = [[NSMutableArray alloc] init];
        }
        
        DLogVerbose(@"{\"Hooks\":\"TLToneManager got tones array: %@\"}",tones);
        
        //Read the ringtone metadata from our own plist
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];
        NSDictionary *importedTones = [toneData importedTones];
        
        for (NSString *file in importedTones) {
            // Create TLItunesTone object and put it into the array
            JFTHRingtone *curTone = [importedTones objectForKey:file];
            DLogDebug(@"{\"Hooks\":\"TLToneManager created JFTHRingtone: %@\"}",curTone);
            
            TLITunesTone *tone = [[%c(TLITunesTone) alloc]
                                  initWithPropertyListRepresentation:[curTone iTunesPlistRepresentation]
                                  filePath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:[curTone fileName]]];
            DLogDebug(@"{\"Hooks\":\"TLToneManager created TLItunesTone: %@\"}",tone);
            
            [curTone release];
            [tones addObject:tone];
            [tone release];
        }
        
        [toneData release];
        [importedTones release];
        //Return the array with the ringtones the system found and the ringtones we have found
        DLogInfo(@"{\"Hooks\":\"TLToneManager Read available ringtones\"}");
        return [tones autorelease];
    } else {
        // Not looking for the ringtones array we're interested in modifying
        DLogVerbose(@"{\"Hooks\":\"TLToneManager Not reading ringtones\"}");
        return %orig;
    }
}*/
%end

%end

/*
HBPreferencesValueChangeCallback updateRingtonePlist = ^(NSString *key, id<NSCopying> _Nullable newValue) {
    NSLog(@"{\"PrefValueChangeCallback\":\"Called in bundle: %@\"}", bundleID);
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) { // ||
        //[[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
        // only run in springboard or preferences
        
        BOOL value = [[(NSNumber *)newValue copy] boolValue];
        DLogDebug(@"{\"Preferences\":\"Notification received for key:%@ with value:%d\"}",key,value);

        if ([key isEqualToString:@"kWriteITunesRingtonePlist"]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[[JFTHRingtoneDataController alloc] init] syncPlists:value];
            });
        }
    }
};

extern NSString *const HBPreferencesDidChangeNotification;*/

#pragma mark - Constructor
//------------- Constructor ------------
%ctor {
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    NSLog(@"{\"Constructor\":\"Loaded in bundle: %@\"}", bundleID);
    
   /* if ([bundleID isEqualToString:@"com.apple.TelephonyUtilities"] ||
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
        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
            [preferences registerPreferenceChangeBlock:(HBPreferencesValueChangeCallback)updateRingtonePlist forKey:@"kWriteITunesRingtonePlist"];
        }

        if (kDebugLogging) {
            
            LogglyFields *logglyFields = [[LogglyFields alloc] init];
            [logglyFields setAppversion:@"0.4.0"];
            
            [logglyFields setUserid:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
            
            LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
            [logglyLogger setLogFormatter:[[LogglyFormatter alloc] initWithLogglyFieldsDelegate:logglyFields]];
            logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
            
            logglyLogger.saveInterval = 600;
            
            [DLog aDLogger:logglyLogger];
            [DLog aDLogger:[DDASLLogger sharedInstance]];
            [logglyFields release];
            [logglyLogger release];
            
        }
        
        [preferences release];
        
        DLogInfo(@"{\"Constructor\":\"Trying to initialize ToneHelper in bundleid: %@\"}",[[NSBundle mainBundle] bundleIdentifier]);
        if (!NSClassFromString(@"TLToneManager")) {
            DLogInfo(@"{\"Constructor\":\"TLToneManager missing, loading framework\"}");
            dlopen("/System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary", RTLD_LAZY);
        }
        /*if (!NSClassFromString(@"TKTonePickerController")) {
            DLogInfo(@"Loading ToneKit");
            dlopen("/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit", RTLD_LAZY);
        }*/
        if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_11_0) {
            //DLogInfo(@"{\"Constructor\":\"Init IOS 11\"}");
            %init(IOS11);
        } else {
            //DLogInfo(@"{\"Constructor\":\"Init IOS 10\"}");
            %init(IOS10);
        }

    //}
}
