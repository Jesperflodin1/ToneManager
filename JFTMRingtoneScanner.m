#import "JFTMRingtoneScanner.h"
#import "JFTMRingtoneDataController.h"
#import "JFTMRingtoneInstaller.h"
#import "JFTMCommonHeaders.h"
#import "JFTMiOSHeaders.h"

@implementation JFTMRingtoneScanner

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        DDLogDebug(@"{\"RingtoneScanner\":\"Init\"}");
    }
    return self;
}

- (void)dealloc {
    DDLogDebug(@"{\"RingtoneScanner\":\"Deallocating scanner\"}");
}


#pragma mark - Search app methods
- (void)importNewRingtonesFromSubfoldersInApps:(NSDictionary *)apps {
    if ([JFTMRingtoneDataController canImport]) {
        for (NSString *bundleID in apps) {
            [self _getNewRingtoneFilesFromApp:bundleID withSubfolder:[apps objectForKey:bundleID]];
        }
        [[self installer] scanDone];
    } else
        DDLogError(@"{\"RingtoneScanner\":\"Something is wrong, we cant import ringtones. Aborting.\"}");
}
// Files with same name from different apps will try to import, but tonelibrary wont import them
- (void)_getNewRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)subfolder {
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory;

    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
    appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:subfolder];
    DDLogInfo(@"{\"RingtoneScanner\":\"listing app folder for bundle: %@\"}",bundleID);

    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    
    DDLogInfo(@"{\"RingtoneScanner\":\"Found these files: %@\"}", appDirFiles);
    
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    
    DDLogDebug(@"{\"RingtoneScanner\":\"App folder available!\"}");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    
    DDLogInfo(@"{\"RingtoneScanner\":\"Found %lu files\"}", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {
            // Check if ringtone already exists
            if ([[[self installer] dataController] isImportedRingtoneWithFilePath:[appDirectory stringByAppendingPathComponent:file]]) {
                DDLogDebug(@"{\"RingtoneScanner\":\"File already imported based on path: %@\"}",file);
                continue;
            }
            
            NSString *toneName = [JFTMRingtoneDataController createNameFromFile:[file stringByDeletingPathExtension]];
            if ([[[self installer] dataController] isImportedRingtoneWithName:toneName]) {
                // filename equals but is from another path(=app)
                DDLogDebug(@"{\"RingtoneScanner\":\"Filename exists but is from another app, forcing import: %@\"}",file);
                
                toneName = [toneName stringByAppendingFormat:@" (%@)",[JFTMRingtoneScanner genRandStringLength:5]]; // append random string
            }
            
            DDLogInfo(@"{\"RingtoneScanner\":\"Adding ringtone to be imported: %@\"}", file);
            NSMutableDictionary *ringtone = [NSMutableDictionary new];
            [ringtone setObject:bundleID forKey:@"BundleID"];
            [ringtone setObject:toneName forKey:@"Name"];
            [ringtone setObject:[appDirectory stringByAppendingPathComponent:file] forKey:@"FullPath"];
            [[self installer] addRingtoneToImport:ringtone];
            //[_ringtoneDataController importTone:[appDirectory stringByAppendingPathComponent:file] fromBundleID:bundleID toneName:toneName];
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