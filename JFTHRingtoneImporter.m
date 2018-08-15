#import "JFTHRingtoneImporter.h"

NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

@implementation JFTHRingtoneImporter

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
- (void)getRingtoneFilesFromApp:(NSString *)bundleID {
    NSLog(@"Ringtone Importer: listing app folder for bundle: %@",bundleID);
    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    if (appDirFiles) {
        if ([appDirFiles count] > 0) {
            for (NSString *file in appDirFiles) {
                if ([[file pathExtension] isEqualToString: @"m4r"]) {
                    [m4rFiles addObject:file];
                }
            }
            if ([m4rFiles count] > 0) {
                // Add files to dict
                NSLog(@"Ringtone Importer: Found ringtones");
                [ringtonesToImport setObject:m4rFiles forKey:bundleID];
                self.shouldImportRingtones = YES;
            }
        }
    } // App unavailable or folder unavailable, not adding
}

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"Ringtone Importer: Init");
        ringtonesToImport = [[NSMutableDictionary alloc] init];
        shouldImportRingtones = NO;
    }
    return self;
}
- (void)showSuccessHUDText:(NSString *)text { //Dismisses itself
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    //self.progressHUD.square = YES;
    HUD.textLabel.text = text;
    [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [HUD dismissAfterDelay:2.0 animated:YES];
}
- (void)showErrorHUDText:(NSString *)text {
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    HUD.textLabel.text = text;
    HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init];
    //self.progressHUD.square = YES;
    [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [HUD dismissAfterDelay:4.0 animated:YES];
}
- (void)showTextHUD {
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    HUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    HUD.animation = [JGProgressHUDFadeZoomAnimation animation];
    HUD.vibrancyEnabled = YES;
    HUD.indicatorView = nil;
    
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"Importing new ringtones" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:15.0]}];
    //[text appendAttributedString:[[NSAttributedString alloc] initWithString:@" Text" attributes:@{NSForegroundColorAttributeName : [UIColor greenColor], NSFontAttributeName: [UIFont systemFontOfSize:11.0]}]];
    
    HUD.textLabel.attributedText = text;
    HUD.position = JGProgressHUDPositionBottomCenter;
    [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [HUD dismissAfterDelay:4.0];
}


- (BOOL)shouldImportRingtones {
    //Check if new ringtones exist
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
- (void)importNewRingtones {
    // Read ringtones.plist
    NSLog(@"Ringtone Importer: Import called");
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


    // Loop through files
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    int importedCount = 0;
    int failedCount = 0;
    for (NSString *bundleID in ringtonesToImport) // loop through all bundle ids
    { 
        FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        for (NSString *appDirFile in [ringtonesToImport objectForKey:bundleID]) //loop through nsarray
        {
            NSError *error;
            // Create new filename
            NSString *newFile = [[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];
            if ([localFileManager moveItemAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]
                        toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                        error:&error]) 
            {
                // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
                NSString *baseName = [appDirFile stringByDeletingPathExtension];
                NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
                baseName = [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                //Plist data
                NSMutableDictionary *currentTone = [[NSMutableDictionary alloc] init];
                [currentTone setObject:[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtoneGUID] forKey:@"GUID"];
                [currentTone setObject:baseName forKey:@"Name"];
                [currentTone setObject:[NSNumber numberWithLongLong:[[JFTHRingtoneImporter randomizedRingtoneParameter:JFTHRingtonePID] longLongValue]] forKey:@"PID"];
                [currentTone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
                // Add entry to nsmutabledict (plist)
                [[plist objectForKey:@"Ringtones"] setObject:currentTone forKey:newFile];
                //NSLog(@"File copy success: %@",appDirFile);
                importedCount++;
            } else {
                failedCount++;
                NSLog(@"File copy (%@) failed: %@",appDirFile,error);
            }
        }
    } // for loop end 
    [self saveRingtonesPlist];
    if (failedCount < 1) {
        [self showSuccessHUDText:[NSString stringWithFormat:@"Imported %d tones", importedCount]];
    } else {
        [self showErrorHUDText:@"Error when importing tones"];
    }
    
}

@end