#import "JFTHRingtoneImporter.h"


NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";
BOOL kWriteITunesRingtonePlist;

extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;



@implementation JFTHRingtoneImporter

- (instancetype)init {
    if (self = [super init]) {
        DDLogInfo(@"Ringtone Importer: Init");
        ringtonesToImport = [[NSMutableDictionary alloc] init];
        shouldImportRingtones = NO;

        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];

        _ringtoneData = [[JFTHRingtoneDataController alloc] init];
        self.importedCount = 0;
        
        if (kWriteITunesRingtonePlist)
            [_ringtoneData enableITunesRingtonePlistEditing];

        DDLogDebug(@"kWriteITunesRingtonePlist: %d",kWriteITunesRingtonePlist);

        
    }
    return self;
}


- (void)getRingtoneFilesFromApp:(NSString *)bundleID {
    DDLogInfo(@"Ringtone Importer: listing app folder for bundle: %@",bundleID);
    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    DDLogInfo(@"Ringtone Importer: Found these files: %@", appDirFiles);
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    DDLogDebug(@"Ringtone Importer: App folder available!");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    DDLogInfo(@"Ringtone Importer: Found %lu files", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        @autoreleasepool {
            if ([[file pathExtension] isEqualToString: @"m4r"]) {

                // Check if ringtone already exists
                if ([_ringtoneData getRingtoneWithName:[self createNameFromFile:file]]) {
                    continue;
                }
                // Does this name already exist in itunes plist?
                NSString *baseName = [self createNameFromFile:file];
                if ([_ringtoneData getITunesRingtoneWithName:baseName]) {
                    DDLogWarn(@"Ringtone is already in itunes plist, name: %@", baseName);
                    continue;
                }
                if ([_ringtoneData getRingtoneWithHash:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]]) {
                    continue;
                }
                DDLogInfo(@"Adding ringtone to be imported: %@", file);
                [m4rFiles addObject:file];
            }
        }
    }

    if ([m4rFiles count] > 0) {
        // Add files to dict
        DDLogInfo(@"Ringtone Importer: Found ringtones");
        [ringtonesToImport setObject:m4rFiles forKey:bundleID];
        self.shouldImportRingtones = YES;
    } else {
        DDLogInfo(@"Found 0 ringtones to import");
        //[self showTextHUD:@"No new ringtones to import"];
        //[_textHUD dismissAfterDelay:3.0 animated:YES];
    }
}

- (BOOL)shouldImportRingtones {
    DDLogDebug(@"Ringtone Importer: shouldImport called value: %d",shouldImportRingtones);
    return shouldImportRingtones;
}
- (void)setShouldImportRingtones:(BOOL)b {
    shouldImportRingtones = b;
}


- (void)importNewRingtones {
    DDLogInfo(@"Ringtone Importer: Import called");
    //[self showTextHUD:@"Importing ringtones..."];

    // Loop through files
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    self.importedCount = 0;
    int failedCount = 0;
    for (NSString *bundleID in ringtonesToImport) // loop through all bundle ids, one app at a time
    { 
        FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        for (NSString *appDirFile in [ringtonesToImport objectForKey:bundleID]) //loop through nsarray of m4r files
        {
            @autoreleasepool {

                // Create name
                NSString *baseName = [self createNameFromFile:appDirFile];

                // Does this name already exist in itunes plist?
                if ([_ringtoneData getITunesRingtoneWithName:baseName]) {
                    DDLogInfo(@"Ringtone is already in itunes plist, name: %@", baseName);
                    continue;
                }


                // Create new filename
                NSString *newFile = [[_ringtoneData randomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];

                // Calculate MD5
                NSString *m4rFileMD5Hash = [FileHash md5HashOfFileAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]];
                NSError *fileCopyError;
                if ([localFileManager copyItemAtPath:[
                    oldDirectory stringByAppendingPathComponent:appDirFile]
                                                         toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                          error:&fileCopyError]) // Will import again at next run if moving. i dont want that.
                {

                    //Plist data
                    [_ringtoneData addRingtoneToPlist:baseName file:newFile oldFileName:appDirFile importedFrom:bundleID hash:m4rFileMD5Hash];
                    DDLogInfo(@"File copy success: %@",appDirFile);
                    self.importedCount++;
                } else if ([localFileManager fileExistsAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]]) {
                        DDLogWarn(@"File already exists, skipping file");
                        // this is wrong: filename will be random every time
                } else {
                    DDLogError(@"File copy (%@) failed and it does not exist in target folder: %@",appDirFile, fileCopyError);
                    // Directory may not exist, try to create it
                    NSError *dirError;
                    if ([localFileManager createDirectoryAtPath:RINGTONE_DIRECTORY
                                    withIntermediateDirectories:YES
                                                     attributes:nil
                                                          error:&dirError]) {
                        DDLogWarn(@"Ringtone folder created");
                        if ([localFileManager copyItemAtPath:[ // Lets try again
                            oldDirectory stringByAppendingPathComponent:appDirFile]
                                                                toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                                error:nil]) // Will import again at next run if moving. i dont want that.
                        {

                            //Plist data
                            [_ringtoneData addRingtoneToPlist:baseName file:newFile oldFileName:appDirFile importedFrom:bundleID hash:m4rFileMD5Hash];
                            DDLogInfo(@"File copy success: %@",appDirFile);
                            self.importedCount++;
                        }
                    } else {
                        DDLogError(@"Failed to create directory: %@", dirError);
                        failedCount++;
                    }
                    
                }
            }
        }
    } // for loop end 
    [_ringtoneData save];
    if ((failedCount == 0) && (self.importedCount > 0)) {
        //[self showSuccessHUDText:[NSString stringWithFormat:@"Imported %d tones", importedCount]];
        //[_statusHUD dismissAfterDelay:1.5 animated:YES];
    } else if (failedCount > 0) {
        //[self showErrorHUDText:@"Error when importing tones"];
        //[_statusHUD dismissAfterDelay:1.5 animated:YES];
    }
    //[_textHUD dismissAfterDelay:2.5 animated:YES];
}

- (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

@end
