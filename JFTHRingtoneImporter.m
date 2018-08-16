#import "JFTHRingtoneImporter.h"

NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

@implementation JFTHRingtoneImporter

- (instancetype)init {
    if (self = [super init]) {
        [self showTextHUD:@"Looking for new ringtones"];
        NSLog(@"Ringtone Importer: Init");
        ringtonesToImport = [[NSMutableDictionary alloc] init];
        shouldImportRingtones = NO;
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

    //Prepare to enter loop when we decide to import or not
    BOOL exists;
    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {

            // Check if ringtone already exists
            exists = NO;

            if (!plist) {
                [self loadRingtonesPlist];
            }
            NSDictionary *ringtones = [plist objectForKey:@"Ringtones"];

            for (NSDictionary *item in ringtones) {
                if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:[self createNameFromFile:file]]) {
                    exists = YES;
                    NSLog(@"Ringtone Importer: Found ringtone that already is imported, skipping. (%@)",item);
                    break; // break this for loop, only looking for one item
                }
            }
            if (exists) continue;

            if (!md5ExistingRingtones) { // get md5 of ringtones if not already done that
                NSLog (@"Ringtone Importer: Getting md5 of existing tones");
                md5ExistingRingtones = [self getMD5ForExistingRingtones];
            }
            if ([md5ExistingRingtones containsObject:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]]) {
                NSLog(@"Ringtone Importer: Found ringtone in ringtone folder with matching md5. Skipping.");
                exists = YES;
                continue; // Found ringtone with matching md5. Dont import. This might be slow. Move to import method?
            }
            if (!exists) { // if not already in ringtones.plist and file not nil
                NSLog(@"Adding ringtone to be imported: %@", file);
                [m4rFiles addObject:file];
            } else {
                NSLog(@"Ringtone Importer: This file already exists: %@", file);
            }
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
    
     // App unavailable or folder unavailable, not adding
}

- (BOOL)shouldImportRingtones {
    NSLog(@"Ringtone Importer: shouldImport called");
    return shouldImportRingtones;
}
- (void)setShouldImportRingtones:(BOOL)b {
    shouldImportRingtones = b;
}
- (void)saveRingtonesPlist {
    //Write plist
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: plist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: nil];
    [newData writeToFile:RINGTONE_PLIST_PATH atomically:YES];
}
- (void)loadRingtonesPlist {
    NSLog(@"Ringtone Importer: Loading Ringtones.plist");
    NSData *plistData = [NSData dataWithContentsOfFile:RINGTONE_PLIST_PATH];
    NSMutableDictionary *ringtones;
    if (plistData) { //if plist exists, read it
        plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                            options:NSPropertyListMutableContainers
                                                            format:nil error:nil];
        ringtones = [plist objectForKey:@"Ringtones"];
    } else { //create new plist
        ringtones = [[NSMutableDictionary alloc] init];
        plist = [[NSMutableDictionary alloc] init];
        [plist setObject:ringtones forKey:@"Ringtones"];
    }
}

- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName {
    if (!plist)
        [self loadRingtonesPlist];
    // name (show in ringtonepicker)
    //filename (filename of m4r file)
    NSMutableDictionary *currentTone = [[NSMutableDictionary alloc] init];
    [currentTone setObject:[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtoneGUID] forKey:@"GUID"];
    [currentTone setObject:name forKey:@"Name"];
    [currentTone setObject:[NSNumber numberWithLongLong:[[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtonePID] longLongValue]] forKey:@"PID"];
    [currentTone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
    // Add entry to nsmutabledict (plist)
    [[plist objectForKey:@"Ringtones"] setObject:currentTone forKey:fileName];
    // Does not save plist automatically. call saveRingtonesPlist when done.
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
            // Calculate MD5 to compare with existing
            //NSString *m4rFileMD5Hash = [FileHash md5HashOfFileAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]];
            
            // Create name
            NSString *baseName = [self createNameFromFile:appDirFile];

            // Create new filename
            NSString *newFile = [[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];

            if ([localFileManager copyItemAtPath:[
                oldDirectory stringByAppendingPathComponent:appDirFile]
                                                     toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                      error:nil]) // Will import again at next run if moving. i dont want that.
            {
                if (!plist) {
                [self loadRingtonesPlist];
                }
                //Plist data
                [self addRingtoneToPlist:baseName file:newFile];
                //NSLog(@"File copy success: %@",appDirFile);
                importedCount++;
            } else {
                failedCount++;
                NSLog(@"File copy (%@) failed",appDirFile);
            }
        }
    } // for loop end 
    [self saveRingtonesPlist];
    if (failedCount == 0) {
        [self showSuccessHUDText:[NSString stringWithFormat:@"Imported %d tones", importedCount]];
    } else {
        [self showErrorHUDText:@"Error when importing tones"];
    }
    [_textHUD dismissAfterDelay:2.0 animated:YES];
}

// MD5 for ringtones in itunes folder. To be used when deciding if ringtone found in app already is imported or not
// Store these in a plist so we wont have to recalculate every time? Would be nice.
- (NSSet *)getMD5ForExistingRingtones {
    NSMutableSet *md5Ringtones = [NSMutableSet new];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSArray *m4rFiles = [localFileManager contentsOfDirectoryAtPath:RINGTONE_DIRECTORY error:nil];

    for (NSString *file in m4rFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {
            NSLog (@"Ringtone Importer: Calling md5 for path: %@", [RINGTONE_DIRECTORY stringByAppendingPathComponent:file]);
            [md5Ringtones addObject:[FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:file]]];
        }
    }

    return md5Ringtones;
}

- (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

- (void)showSuccessHUDText:(NSString *)text { //Dismisses itself
    _statusHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    //self.progressHUD.square = YES;
    _statusHUD.textLabel.text = text;
    [_statusHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [_statusHUD dismissAfterDelay:4.0 animated:YES];
}
- (void)showErrorHUDText:(NSString *)text {
    _statusHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    _statusHUD.textLabel.text = text;
    _statusHUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    //self.progressHUD.square = YES;
    [_statusHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [_statusHUD dismissAfterDelay:5.0 animated:YES];
}
- (void)showTextHUD:(NSString *)text {
    if (_textHUD) {
        [_textHUD dismissAnimated:YES];
    }
    _textHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleDark];
    _textHUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    _textHUD.animation = [JGProgressHUDFadeZoomAnimation animation];
    _textHUD.vibrancyEnabled = NO;
    _textHUD.indicatorView = nil;
    
    NSMutableAttributedString *attrText = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor orangeColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    //[text appendAttributedString:[[NSAttributedString alloc] initWithString:@" Text" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:11.0]}]];
    
    _textHUD.textLabel.attributedText = attrText;
    _textHUD.position = JGProgressHUDPositionBottomCenter;
    [_textHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    //[_textHUD dismissAfterDelay:delay animated:YES];
    _textHUD = nil;
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