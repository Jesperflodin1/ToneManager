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
            if ([_ringtoneDataController isImportedRingtoneWithFilePath:[appDirectory stringByAppendingPathComponent:file]]) {
                DDLogDebug(@"{\"Ringtone Import\":\"File already imported based on path: %@\"}",file);
                continue;
            }
            
            NSString *toneName = [JFTHRingtoneDataController createNameFromFile:[file stringByDeletingPathExtension]];
            if ([_ringtoneDataController isImportedRingtoneWithName:toneName]) {
                // filename equals but is from another path(=app)
                DDLogDebug(@"{\"Ringtone Import\":\"Filename exists but is from another app, forcing import: %@\"}",file);
                
                toneName = [toneName stringByAppendingFormat:@" (%@)",[JFTHRingtoneScanner genRandStringLength:5]]; // append random string
            }
            
            DDLogInfo(@"{\"Ringtone Import\":\"Adding ringtone to be imported: %@\"}", file);
            [_ringtoneDataController importTone:[appDirectory stringByAppendingPathComponent:file] fromBundleID:bundleID toneName:toneName];
        }
    }
}

// Generates alpha-numeric-random string
+ (NSString *)genRandStringLength:(int)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}

@end
