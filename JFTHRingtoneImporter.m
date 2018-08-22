#import "JFTHRingtoneImporter.h"


NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";
BOOL kWriteITunesRingtonePlist;

extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;



@implementation JFTHRingtoneImporter

- (instancetype)init {
    if (self = [super init]) {
        //[self showTextHUD:@"Looking for new ringtones"];
        ALog(@"Ringtone Importer: Init");
        ringtonesToImport = [[NSMutableDictionary alloc] init];
        shouldImportRingtones = NO;

        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];

        _ringtoneData = [[JFTHRingtoneDataController alloc] init];
        
        if (kWriteITunesRingtonePlist)
            [_ringtoneData enableITunesRingtonePlistEditing];

        DLog(@"kWriteITunesRingtonePlist: %d",kWriteITunesRingtonePlist);

        
    }
    return self;
}


- (void)getRingtoneFilesFromApp:(NSString *)bundleID {
    ALog(@"Ringtone Importer: listing app folder for bundle: %@",bundleID);
    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    DLog (@"Ringtone Importer: Found these files: %@", appDirFiles);
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    DLog (@"Ringtone Importer: App folder available!");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    DLog (@"Ringtone Importer: Found %lu files", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {

            // Check if ringtone already exists
            if ([_ringtoneData getRingtoneWithName:[self createNameFromFile:file]]) {
                continue;
            }
            if ([_ringtoneData getRingtoneWithHash:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]]) {
                continue;
            }
            DLog(@"Adding ringtone to be imported: %@", file);
            [m4rFiles addObject:file];
        }
    }

    if ([m4rFiles count] > 0) {
        // Add files to dict
        ALog(@"Ringtone Importer: Found ringtones");
        [ringtonesToImport setObject:m4rFiles forKey:bundleID];
        self.shouldImportRingtones = YES;
    } else {
        ALog(@"Found 0 ringtones to import");
        [self showTextHUD:@"No new ringtones to import"];
        [_textHUD dismissAfterDelay:3.0 animated:YES];
    }
}

- (BOOL)shouldImportRingtones {
    DLog(@"Ringtone Importer: shouldImport called");
    return shouldImportRingtones;
}
- (void)setShouldImportRingtones:(BOOL)b {
    shouldImportRingtones = b;
}


- (void)importNewRingtones {
    ALog(@"Ringtone Importer: Import called");
    [self showTextHUD:@"Importing ringtones..."];

    // Loop through files
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    int importedCount = 0;
    int failedCount = 0;
    for (NSString *bundleID in ringtonesToImport) // loop through all bundle ids, one app at a time
    { 
        FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        for (NSString *appDirFile in [ringtonesToImport objectForKey:bundleID]) //loop through nsarray of m4r files
        {

            // Create name
            NSString *baseName = [self createNameFromFile:appDirFile];

            // Does this name already exist in itunes plist?
            if (_ringtoneData getITunesRingtoneWithName:baseName)
                continue;


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
                DLog(@"File copy success: %@",appDirFile);
                importedCount++;
            } else if ([localFileManager fileExistsAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]]) {
                    DLog(@"File already exists, skipping file");
                    // this is wrong: filename will be random every time
            } else {
                ALog(@"File copy (%@) failed and it does not exist in target folder: %@",appDirFile, fileCopyError);
                // Directory may not exist, try to create it
                NSError *dirError;
                if ([localFileManager createDirectoryAtPath:RINGTONE_DIRECTORY
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&dirError]) {
                    ALog(@"Ringtone folder created");
                    if ([localFileManager copyItemAtPath:[ // Lets try again
                        oldDirectory stringByAppendingPathComponent:appDirFile]
                                                            toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                            error:nil]) // Will import again at next run if moving. i dont want that.
                    {

                        //Plist data
                        [_ringtoneData addRingtoneToPlist:baseName file:newFile oldFileName:appDirFile importedFrom:bundleID hash:m4rFileMD5Hash];
                        DLog(@"File copy success: %@",appDirFile);
                        importedCount++;
                    }
                } else {
                    ALog(@"Failed to create directory: %@", dirError);
                    failedCount++;
                }
                
            }
        }
    } // for loop end 
    [_ringtoneData save];
    if ((failedCount == 0) && (importedCount > 0)) {
        [self showSuccessHUDText:[NSString stringWithFormat:@"Imported %d tones", importedCount]];
        [_statusHUD dismissAfterDelay:1.5 animated:YES];
    } else if (failedCount > 0) {
        [self showErrorHUDText:@"Error when importing tones"];
        [_statusHUD dismissAfterDelay:1.5 animated:YES];
    }
    [_textHUD dismissAfterDelay:2.5 animated:YES];
}

- (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

- (void)showSuccessHUDText:(NSString *)text { //Dismisses itself
if (_statusHUD) {
        if ([_statusHUD isVisible]) 
            [_statusHUD dismissAnimated:NO];
    }
    _statusHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    _statusHUD.vibrancyEnabled = NO;
    _statusHUD.square = YES;
    _statusHUD.textLabel.text = text;
    [_statusHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //[_statusHUD dismissAfterDelay:2.0 animated:YES];
}
- (void)showErrorHUDText:(NSString *)text {
    if (_statusHUD) {
        if ([_statusHUD isVisible]) 
            [_statusHUD dismissAnimated:NO];
    }
    _statusHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    _statusHUD.vibrancyEnabled = NO;
    _statusHUD.textLabel.text = text;
    _statusHUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    _statusHUD.square = YES;
    [_statusHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //[_statusHUD dismissAfterDelay:3.0 animated:YES];
}
- (void)showTextHUD:(NSString *)text {
    if (_textHUD) {
        if ([_textHUD isVisible]) 
            [_textHUD dismissAnimated:NO];
    }
    _textHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    _textHUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    _textHUD.animation = [JGProgressHUDFadeZoomAnimation animation];
    _textHUD.vibrancyEnabled = NO;
    _textHUD.indicatorView = nil;
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    //[text appendAttributedString:[[NSAttributedString alloc] initWithString:@" Text" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:11.0]}]];
    
    _textHUD.textLabel.attributedText = attrText;
    _textHUD.position = JGProgressHUDPositionBottomCenter;
    [_textHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //[_textHUD dismissAfterDelay:delay animated:YES];
}

@end