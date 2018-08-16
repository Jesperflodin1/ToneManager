#import "JFTHRingtoneImporter.h"


NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

@implementation JFTHRingtoneImporter

- (instancetype)init {
    if (self = [super init]) {
        [self showTextHUD:@"Looking for new ringtones"];
        NSLog(@"Ringtone Importer: Init");
        ringtonesToImport = [[NSMutableDictionary alloc] init];
        shouldImportRingtones = NO;

        _ringtoneData = [[JFTHRingtoneDataController alloc] init];
    }
    return self;
}


- (void)getRingtoneFilesFromApp:(NSString *)bundleID {
    NSLog(@"Ringtone Importer: listing app folder for bundle: %@",bundleID);
    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    NSLog (@"Ringtone Importer: Found these files: %@", appDirFiles);
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    NSLog (@"Ringtone Importer: App folder available!");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    NSLog (@"Ringtone Importer: Found %lu files", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {

            // Check if ringtone already exists
            if ([_ringtoneData getRingtoneWithName:[self createNameFromFile:file]]) {
                continue;
            }
            if ([_ringtoneData getRingtoneWithHash:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]]) {
                continue;
            }
            NSLog(@"Adding ringtone to be imported: %@", file);
            [m4rFiles addObject:file];
        }
    }

    if ([m4rFiles count] > 0) {
        // Add files to dict
        NSLog(@"Ringtone Importer: Found ringtones");
        [ringtonesToImport setObject:m4rFiles forKey:bundleID];
        self.shouldImportRingtones = YES;
    } else {
        [self showTextHUD:@"Nothing to import"];
        [_textHUD dismissAfterDelay:4.0 animated:YES];
    }
}

- (BOOL)shouldImportRingtones {
    NSLog(@"Ringtone Importer: shouldImport called");
    return shouldImportRingtones;
}
- (void)setShouldImportRingtones:(BOOL)b {
    shouldImportRingtones = b;
}


- (void)importNewRingtones {
    NSLog(@"Ringtone Importer: Import called");
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

            // Create new filename
            NSString *newFile = [[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];

            // Calculate MD5
            NSString *m4rFileMD5Hash = [FileHash md5HashOfFileAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]];

            if ([localFileManager copyItemAtPath:[
                oldDirectory stringByAppendingPathComponent:appDirFile]
                                                     toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                      error:nil]) // Will import again at next run if moving. i dont want that.
            {

                //Plist data
                [_ringtoneData addRingtoneToPlist:baseName file:newFile oldFileName:appDirFile importedFrom:bundleID hash:m4rFileMD5Hash];
                NSLog(@"File copy success: %@",appDirFile);
                importedCount++;
            } else {
                failedCount++;
                NSLog(@"File copy (%@) failed",appDirFile);
            }
        }
    } // for loop end 
    [_ringtoneData save];
    if (failedCount == 0) {
        [self showSuccessHUDText:[NSString stringWithFormat:@"Imported %d tones", importedCount]];
    } else {
        [self showErrorHUDText:@"Error when importing tones"];
    }
    [_textHUD dismissAfterDelay:2.0 animated:YES];
}

- (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

- (void)showSuccessHUDText:(NSString *)text { //Dismisses itself
    _statusHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
    _statusHUD.vibrancyEnabled = YES;
    //self.progressHUD.square = YES;
    _statusHUD.textLabel.text = text;
    [_statusHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [_statusHUD dismissAfterDelay:4.0 animated:YES];
}
- (void)showErrorHUDText:(NSString *)text {
    _statusHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
    _statusHUD.vibrancyEnabled = YES;
    _statusHUD.textLabel.text = text;
    _statusHUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    //self.progressHUD.square = YES;
    [_statusHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [_statusHUD dismissAfterDelay:5.0 animated:YES];
}
- (void)showTextHUD:(NSString *)text {
    if (_textHUD) {
        [_textHUD dismissAnimated:NO];
    }
    _textHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
    _textHUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    _textHUD.animation = [JGProgressHUDFadeZoomAnimation animation];
    _textHUD.vibrancyEnabled = YES;
    _textHUD.indicatorView = nil;
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    //[text appendAttributedString:[[NSAttributedString alloc] initWithString:@" Text" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:11.0]}]];
    
    _textHUD.textLabel.attributedText = attrText;
    _textHUD.position = JGProgressHUDPositionBottomCenter;
    [_textHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //[_textHUD dismissAfterDelay:delay animated:YES];
}

// Generates filename, PID and GUID needed to import ringtone
+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type {
    int length;
    NSString *alphabet;
    NSString *result = @"";
    switch (Type) 
    {
        case JFTHRingtonePID:
            length = 18;
            result = @"-";
            alphabet = @"0123456789";
            break;
        case JFTHRingtoneGUID:
            alphabet = @"ABCDEFG0123456789";
            length = 16;
            break;
        case JFTHRingtoneFileName:
            alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXZ";
            length = 4;
            break;
        default:
            return nil;
            break;
    }
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0U; i < length; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [result stringByAppendingString:s];
}

@end