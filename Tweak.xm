#import "ToneHelper.h"
#import "JFTHRingtoneImporter.h"

#import <objc/runtime.h>



NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

BOOL kEnabled;
BOOL kAudikoLiteEnabled;
BOOL kAudikoPaidEnabled;
BOOL kZedgeEnabled;
BOOL kWriteITunesRingtonePlist;
extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;
HBPreferencesValueChangeCallback updateRingtonePlist = ^(NSString *key, id<NSCopying> _Nullable newValue) {
    BOOL value = [[(NSNumber *)newValue copy] boolValue];
    DLog(@"Notification received for key:%@ with value:%d",key,value);
    if ([key isEqualToString:@"kWriteITunesRingtonePlist"]) {
        [JFTHRingtoneDataController syncPlists:value];
    }
};


// TODO: 
//
// Add support for zedge ringtones
//
// Test with both Audiko Lite and Pro
%group ToneHelper

%hook TLToneManager

//Gets called once when opening the ringtone settings
-(void)_loadITunesRingtoneInfoPlistAtPath:(id)arg1 {
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        DLog(@"In preferences");
        if (!kEnabled) {
            DLog(@"Disabled");
            return %orig;
        }
        DLog(@"Enabled");
        //We're in preferences app, lets look for new ringtones to import
        JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];

        //Apps to look for ringtones in (in Documents folder)
        NSMutableArray *apps = [[NSMutableArray alloc] init];
        if (kAudikoLiteEnabled)
            [apps addObject:@"com.908.AudikoFree"];
        if (kZedgeEnabled)
            [apps addObject:@"com.zedge.Zedge"];
        if (kAudikoLiteEnabled)
            [apps addObject:@"com.908.Audiko"];

        for (NSString *app in apps) {
            [importer getRingtoneFilesFromApp:app];
        }
        //Found something new to import?
        if ([importer shouldImportRingtones]) {
            [importer importNewRingtones];
        }
    }
    return %orig;
}


-(NSMutableArray *)_tonesFromManifestPath:(NSPathStore2 *)arg1 mediaDirectoryPath:(NSPathStore2 *)arg2 {
    if (!kEnabled || kWriteITunesRingtonePlist) {
        // kWriteITunesRingtonePlist enabled => disable runtime injection of ringtones
        DLog(@"Disabled");
        return %orig;
    }
    DLog(@"Enabled");
    DLog(@"In tonemanager");
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
        DLog(@"Read available ringtones");
        return tones;
    } else {
        // Not looking for the ringtones array we're interested in modifying
        DLog(@"Not reading ringtones");
        return %orig;
    }
}
%end

%end



%ctor {
    //NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    DLog(@"Trying to initialize ToneHelper in bundleid: %@",[[NSBundle mainBundle] bundleIdentifier]);
   // if ([bundleID isEqualToString:@"com.apple.Preferences"] ||
   //     [bundleID isEqualToString:@"com.apple.springboard"] ||
   //     [bundleID isEqualToString:@"com.apple.InCallService"] ||
   //     [bundleID isEqualToString:@"com.apple.MobileSMS"]) {
        DLog(@"Initializing ToneHelper");
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];

        [preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
        [preferences registerBool:&kAudikoLiteEnabled default:NO forKey:@"kAudikoLiteEnabled"];
        [preferences registerBool:&kAudikoPaidEnabled default:NO forKey:@"kAudikoPaidEnabled"];
        [preferences registerBool:&kZedgeEnabled default:NO forKey:@"kZedgeEnabled"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        

        [preferences registerPreferenceChangeBlock:(HBPreferencesValueChangeCallback)updateRingtonePlist forKey:@"kWriteITunesRingtonePlist"];

        //if () {
        %init(ToneHelper);
        //}
    //}
    
}