#import "JFTHRingtoneScanner.h"
#import "JFTHRingtoneDataController.h"
#import "JFTHCommonHeaders.h"
#import "JFTHiOSHeaders.h"


extern NSString *const HBPreferencesDidChangeNotification;

@interface JFTHRingtoneScanner () {
    NSMutableDictionary *_ringtonesToImport;
    HBPreferences *preferences;
}
@property (nonatomic) JFTHRingtoneDataController *ringtoneDataController;

@end

@implementation JFTHRingtoneScanner

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        DDLogDebug(@"{\"Ringtone Import\":\"Init\"}");
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        DDLogVerbose(@"{\"Preferences\":\"Initializing preferences in importer.\"}");
        _ringtoneDataController = [JFTHRingtoneDataController new];
        _ringtonesToImport = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Search app methods
- (void)importNewRingtonesFromSubfoldersInApps:(NSDictionary *)apps {
    if ([JFTHRingtoneDataController canImport]) {
        for (NSString *bundleID in apps) {
            [self _getNewRingtoneFilesFromApp:bundleID withSubfolder:[apps objectForKey:bundleID]];
        }
    } else
        DDLogError(@"{\"Ringtone Import\":\"Something is wrong, we cant import ringtones. Aborting.\"}");
}
// Files with same name from different apps will try to import, but tonelibrary wont import them
// TODO: check md5 if filename already exists => append random string if different md5?
- (void)_getNewRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)subfolder {
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory;

    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
    appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:subfolder];
    DDLogInfo(@"{\"Ringtone Import\":\"listing app folder for bundle: %@\"}",bundleID);

    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    
    DDLogInfo(@"{\"Ringtone Import\":\"Found these files: %@\"}", appDirFiles);
    
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    
    DDLogDebug(@"{\"Ringtone Import\":\"App folder available!\"}");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    
    DDLogInfo(@"{\"Ringtone Import\":\"Found %lu files\"}", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {
            // Check if ringtone already exists
            // TODO: If filename equals, check if bundleid equals/path equals. If filename equals but not filepath == different file (probably). Append something random (or appname?) to name and import
            if ([_ringtoneDataController isImportedRingtoneWithFilePath:[appDirectory stringByAppendingPathComponent:file]]) {
                DDLogDebug(@"{\"Ringtone Import\":\"File already imported based on path: %@\"}",file);
                continue;
            }
            
            DDLogInfo(@"{\"Ringtone Import\":\"Adding ringtone to be imported: %@\"}", file);
            [_ringtoneDataController importTone:[appDirectory stringByAppendingPathComponent:file] fromBundleID:bundleID toneName:nil];
        }
    }
}

@end
