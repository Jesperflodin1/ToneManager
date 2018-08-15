#import "JFTHRingtoneImporter.h"

NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

@implementation JFTHRingtoneImporter

- (instancetype)init {
    if (self = [super init]) {
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
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;

    //Prepare to enter loop when we decide to import or not
    if (!md5ExistingRingtones)
        NSSet *md5ExistingRingtones = [self getMD5ForExistingRingtones];

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {

            // Check if ringtone already exists
            BOOL exists = NO;

            if (!plist)
                [self loadRingtonesPlist];
            NSDictionary *ringtones = [plist objectForKey:@"Ringtones"];

            for (NSDictionary *item in ringtones) {
                if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:[self createNameFromFile:file]]) {
                    exists = YES;
                    NSLog(@"Ringtone Importer: Found ringtone that already is imported, skipping. (%@)",item);
                }
            }
            if ([md5ExistingRingtones containsObject:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]])
                continue; // Found ringtone with matching md5. Dont import. This might be slow. Move to import method?
            if (!exists) {
                [m4rFiles addObject:file];
            } 
        }
    }

    if ([m4rFiles count] > 0) {
        
        // Add files to dict
        NSLog(@"Ringtone Importer: Found ringtones");
        [ringtonesToImport setObject:m4rFiles forKey:bundleID];
        self.shouldImportRingtones = YES;
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
    // Read ringtones.plist
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
    
}

// MD5 for ringtones in itunes folder. To be used when deciding if ringtone found in app already is imported or not
// Store these in a plist so we wont have to recalculate every time? Would be nice.
- (NSSet *)getMD5ForExistingRingtones {
    NSMutableSet *md5Ringtones = [NSSet new];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSArray *m4rFiles = [localFileManager contentsOfDirectoryAtPath:RINGTONE_DIRECTORY error:nil];

    for (NSString *file in m4rFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {
            [md5Ringtones addObject:[FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingString:file]]];
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
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
    //self.progressHUD.square = YES;
    HUD.textLabel.text = text;
    [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [HUD dismissAfterDelay:4.0 animated:YES];
}
- (void)showErrorHUDText:(NSString *)text {
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
    HUD.textLabel.text = text;
    HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    //self.progressHUD.square = YES;
    [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [HUD dismissAfterDelay:5.0 animated:YES];
}
- (void)showTextHUD:(NSString *)text {
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleLight];
    HUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    HUD.animation = [JGProgressHUDFadeZoomAnimation animation];
    HUD.vibrancyEnabled = NO;
    HUD.indicatorView = nil;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    //[text appendAttributedString:[[NSAttributedString alloc] initWithString:@" Text" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:11.0]}]];
    
    HUD.textLabel.attributedText = text;
    HUD.position = JGProgressHUDPositionBottomCenter;
    [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [HUD dismissAfterDelay:5.0];
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