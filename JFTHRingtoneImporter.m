#import "JFTHRingtoneImporter.h"

BOOL kWriteITunesRingtonePlist;

extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;

@interface JFTHRingtoneImporter () {
    NSMutableDictionary *_ringtonesToImport;
    BOOL _shouldImportRingtones;
    
    JFTHRingtoneDataController *_ringtoneDataController;
}

@end

@implementation JFTHRingtoneImporter

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        DDLogInfo(@"{\"Ringtone Import\":\"Init\"}");
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        
        
        _ringtoneDataController = [[JFTHRingtoneDataController alloc] init];
        
        _ringtonesToImport = [[NSMutableDictionary alloc] init];
        _shouldImportRingtones = NO;

        self.importedCount = 0;
        
        if (kWriteITunesRingtonePlist)
            [_ringtoneDataController enableITunesRingtonePlistEditing];

        DDLogDebug(@"{\"Ringtone Import\":\"kWriteITunesRingtonePlist: %d\"}",kWriteITunesRingtonePlist);
    }
    return self;
}

#pragma mark - Search app method
- (void)getRingtoneFilesFromApp:(NSString *)bundleID {
    DDLogInfo(@"{\"Ringtone Import\":\"listing app folder for bundle: %@\"}",bundleID);
    
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    
    DDLogInfo(@"{\"Ringtone Import\":\"Found these files: %@\"}", appDirFiles);
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    
    DDLogDebug(@"{\"Ringtone Import\":\"App folder available!\"}");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    
    DDLogInfo(@"{\"Ringtone Import\":\"Found %lu files\"}", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {

            // Check if ringtone already exists
            if ([_ringtoneDataController isImportedRingtoneWithName:[self createNameFromFile:file]]) {
                continue;
            }
            
            // Does this name already exist in itunes plist?
            NSString *baseName = [self createNameFromFile:file];
            if ([_ringtoneDataController isITunesRingtoneWithName:baseName]) {
                DDLogWarn(@"{\"Ringtone Import\":\"Ringtone is already in itunes plist, name: %@\"}", baseName);
                continue;
            }
            if ([_ringtoneDataController isImportedRingtoneWithHash:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]]) {
                continue;
            }
            DDLogInfo(@"{\"Ringtone Import\":\"Adding ringtone to be imported: %@\"}", file);
            [m4rFiles addObject:file];
        }
    }
    if ([m4rFiles count] > 0) {
        // Add files to dict
        DDLogInfo(@"{\"Ringtone Import\":\"Found ringtones to import\"}");
        [_ringtonesToImport setObject:m4rFiles forKey:bundleID];
        _shouldImportRingtones = YES;
        
    } else {
        DDLogInfo(@"{\"Ringtone Import\":\"Found 0 ringtones to import\"}");
    }
}

#pragma mark - Should import methods
- (BOOL)shouldImportRingtones {
    DDLogDebug(@"{\"Ringtone Import\":\"shouldImport called with value: %d\"}",_shouldImportRingtones);
    return _shouldImportRingtones;
}

#pragma mark - Import
- (void)importNewRingtones {
    DDLogInfo(@"{\"Ringtone Import\":\"Import called\"}");

    // Loop through files
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    self.importedCount = 0;
    
    for (NSString *bundleID in _ringtonesToImport) // loop through all bundle ids, one app at a time
    { 
        FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        
        for (NSString *appDirFile in [_ringtonesToImport objectForKey:bundleID]) //loop through nsarray of m4r files
        {
            @autoreleasepool {

                // Create name
                NSString *baseName = [self createNameFromFile:appDirFile];

                // Create new filename
                NSString *newFile = [[JFTHRingtone randomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];

                NSError *fileCopyError;
                if ([localFileManager copyItemAtPath:[
                    oldDirectory stringByAppendingPathComponent:appDirFile]
                                                         toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                          error:&fileCopyError]) // Will import again at next run if moving. i dont want that.
                {
                    DDLogInfo(@"{\"Ringtone Import\":\"File copy success: %@\"}",appDirFile);
                    //Plist data
                    JFTHRingtone *newTone = [[JFTHRingtone alloc] initWithName:baseName
                                                                      fileName:newFile
                                                                   oldFileName:appDirFile
                                                                      bundleID:bundleID];
                    [_ringtoneDataController addRingtoneToPlist:newTone];
                    
                    self.importedCount++;

                } else {
                    DDLogError(@"{\"Ringtone Import\":\"File copy (%@) failed: %@\"}",appDirFile, fileCopyError);
                }
            }
        }
    }
}

#pragma mark - Namecreator
- (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

@end
