#import "ToneHelper.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import "JFTHRingtoneImporter.h"

// TODO: 
//
// Add support for zedge ringtones
//
// Test with both Audiko Lite and Pro
%group ios11

%hook TLToneManager

-(void)_loadITunesRingtoneInfoPlistAtPath:(id)arg1 {
    NSLog(@"loadITunesRingtoneInfoPlistAtPath: %@", arg1);
    JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];

    //Apps to look for ringtones in (in Documents folder)
    NSMutableArray *apps = [[NSMutableArray alloc] init];
    [apps addObject:@"com.908.AudikoFree"];
    for (NSString *app in apps) {
        [importer getRingtoneFilesFromApp:app];
    }

    if ([importer shouldImportRingtones]) {
        [importer importNewRingtones];
    }

    %orig;
}

%end

%end

%ctor {
    %init(ios11);
}