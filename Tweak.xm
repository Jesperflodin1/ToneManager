#import "ToneHelper.h"
#import "JFTHRingtoneImporter.h"

#import <objc/runtime.h>



NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

BOOL kEnabled;
BOOL kAudikoLiteEnabled;
BOOL kAudikoPaidEnabled;
BOOL kZedgeEnabled;
HBPreferences *preferences;


// TODO: 
//
// Add support for zedge ringtones
//
// Test with both Audiko Lite and Pro
%group ios11

%hook TLToneManager

-(void)_loadITunesRingtoneInfoPlistAtPath:(id)arg1 {
    if (!kEnabled) {
        DLog(@"Disabled");
        return %orig;
    }
    DLog(@"Enabled");
    //Gets called once when opening the ringtone settings
    if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.Preferences"]) {
        //We're in preferences app, lets look for new ringtones to import
        JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];

        //Apps to look for ringtones in (in Documents folder)
        NSMutableArray *apps = [[NSMutableArray alloc] init];
        [apps addObject:@"com.908.AudikoFree"];

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
    if (!kEnabled) {
        DLog(@"Disabled");
        return %orig;
    }
    DLog(@"Enabled");
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
        return tones;
    } else {
        // Not looking for the ringtones array we're interested in modifying
        return %orig;
    }
}
%end

%end

extern NSString *const HBPreferencesDidChangeNotification;

%ctor {
    DLog(@"Initializing ToneHelper")
    preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];

	[preferences registerBool:&kEnabled default:NO forKey:@"kEnabled"];
    [preferences registerBool:&kAudikoLiteEnabled default:NO forKey:@"kAudikoLiteEnabled"];
    [preferences registerBool:&kAudikoPaidEnabled default:NO forKey:@"kAudikoPaidEnabled"];
    [preferences registerBool:&kZedgeEnabled default:NO forKey:@"kZedgeEnabled"];

    %init(ios11);
}