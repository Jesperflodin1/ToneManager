#import "ToneHelper.h"
#import "JGProgressHUD/JGProgressHUD.h"
#import "JFTHRingtoneImporter.h"

// TODO: 
//
// Add support for zedge ringtones
//
// Test with both Audiko Lite and Pro
%group inToneKit

%hook TKTonePickerController

- (id)_loadTonesFromPlistNamed:(id)arg1 {
    JFTHRingtoneImporter *importer = [[JFTHRingtoneImporter alloc] init];
	NSLog(@"DEBUG: _loadTonesFromPlistNamed arg1=%@", arg1);
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];

    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier: @"com.908.AudikoFree"];

    if ([arg1 isEqualToString:@"TKRingtones"]) {
        HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        HUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
        HUD.animation = [JGProgressHUDFadeZoomAnimation animation];
        HUD.shadow = [JGProgressHUDShadow shadowWithColor:[UIColor blackColor] offset:CGSizeZero radius:5.0 opacity:0.3f];
        HUD.vibrancyEnabled = YES;
        HUD.detailTextLabel.text = @"0% Complete";
        HUD.textLabel.text = @"Loading";
        [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        [HUD setProgress:0.0f animated:YES];
        
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        NSError *appDirError;
        NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:oldDirectory error:&appDirError];
        //TODO: Check if new files that need copying exist ?
        if (appDirFiles) //if folder exists
        {
            HUD.textLabel.text = [NSString stringWithFormat:@"Importing %@ Ringtones",[NSNumber numberWithUnsignedLong:[appDirFiles count]]];
            double progress = 100.0/[appDirFiles count];
            // Get all the files at application documents folder
            //TODO: List folders for multiple applications, if they exist

            NSData *plistData = [NSData dataWithContentsOfFile:RINGTONE_PLIST_PATH];
            NSMutableDictionary *plist;
            NSMutableDictionary *ringtones;
            if (plistData) { //if plist exists, read it
                plist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                    options:NSPropertyListMutableContainers
                                                                    format:nil error:nil];
                ringtones = [plist objectForKey:@"Ringtones"];
                NSLog(@"%@",plist);
            } else { //create new plist
                ringtones = [[NSMutableDictionary alloc] init];
                [plist setObject:ringtones forKey:@"Ringtones"];
            }
            for (NSString *appDirFile in appDirFiles) 
            { 
                if ([[appDirFile pathExtension] isEqualToString: @"m4r"]) 
                {
                    NSLog(@"Copying to path (%@) with extension (%@)",RINGTONE_DIRECTORY,[appDirFile pathExtension]);
                    NSError *error;
                    NSString *newFile = [[JFTHRingtoneImporter JFTH_RandomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];
                    if ([localFileManager copyItemAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]
                                toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                error:&error]) 
                    {
                        // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
                        NSString *baseName = [appDirFile stringByDeletingPathExtension];
                        NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
                        baseName = [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
                        //Plist data
                        NSMutableDictionary *currentTone = [[NSMutableDictionary alloc] init];
                        [currentTone setObject:[JFTHRingtoneImporter JFTH_RandomizedRingtoneParameter:JFTHRingtoneGUID] forKey:@"GUID"];
                        [currentTone setObject:baseName forKey:@"Name"];
                        [currentTone setObject:[NSNumber numberWithLongLong:[[JFTHRingtoneImporter JFTH_RandomizedRingtoneParameter:JFTHRingtonePID] longLongValue]] forKey:@"PID"];
                        [currentTone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
                        [ringtones setObject:currentTone forKey:[[JFTHRingtoneImporter JFTH_RandomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"]];
                        NSLog(@"File copy success: %@",appDirFile);
                    } else {
                        NSLog(@"File copy (%@) failed: %@",appDirFile,error);
                    }
                    [HUD setProgress:progress/100.0f animated:NO];
                    progress += 100.0/[appDirFiles count];
                }
            } // for loop end 
            //Write plist
            NSData *newData = [NSPropertyListSerialization dataWithPropertyList: plist
                                                    format: NSPropertyListXMLFormat_v1_0
                                                    options: 0
                                                        error: nil];
            NSLog(@"Writing plist: %@", RINGTONE_PLIST_PATH);
            [newData writeToFile:RINGTONE_PLIST_PATH atomically:YES];
        }
        
        [HUD setProgress:1.0f animated:YES];
        HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
        HUD.square = YES;
        HUD.textLabel.text = @"Done";
        [HUD dismissAfterDelay:0.3f animated:YES];


        // Enumerate ringtones in ringtones folder and add to return dictionary
        // This may be unneccessary??? (because im basically doing an itunes import)
        /*NSDictionary *original = %orig;
		NSLog(@"orig = %@", original);
        NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
        NSMutableArray *classicRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"classic"]];
        NSMutableArray *modernRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"modern"]];
        
        NSString *tonesDirectory = @"/Library/Ringtones";
        NSDirectoryEnumerator *dirEnum  = [localFileManager enumeratorAtPath:tonesDirectory];
        NSArray *systemToneFiles = [dirEnum allObjects];
        
        for (NSString *file in systemToneFiles)
        {
            if ([[file pathExtension] isEqualToString: @"m4r"])
            {
                NSString *properToneIdentifier = [NSString stringWithFormat:@"system:%@",[file stringByDeletingPathExtension]];
                BOOL isClassicTone = [classicRingtones containsObject:properToneIdentifier];
                BOOL isModernTone  = [modernRingtones containsObject:properToneIdentifier];
                
                if(!isClassicTone && !isModernTone)
                {
                    [modernRingtones addObject:properToneIdentifier];
                }
            }
        }
        
        [allRingtones setObject:classicRingtones forKey:@"classic"];
        [allRingtones setObject:modernRingtones  forKey:@"modern"];
        [HUD setProgress:1.0f animated:NO];
        [HUD dismissAfterDelay:1.0];
        return allRingtones;*/
        return %orig;
        
    } else {
        return %orig;
    }
}

%end

%end

#define XPCObjects "/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit"

%ctor {
    %init(inToneKit);
    /*if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilesafari"]) {
        if (!NSClassFromString(@"TKTonePickerController")) {
            //load the framework if it does not exist
            dlopen(XPCObjects, RTLD_LAZY);
            NSLog(@"DEBUG: Loading ToneKit Framework");
        }
        
        if (NSClassFromString(@"TKTonePickerController")) {
            NSLog(@"ToneHelper initializing...");
            %init(inToneKit);
        } else
            NSLog(@"DEBUG: ToneHelper not initializing. What is happening?!");
    }*/
}