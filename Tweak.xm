#import "ToneHelper.h"
#import "JGProgressHUD/JGProgressHUD.h"

// TODO: 
//
// Add support for zedge ringtones
//
// Test with both Audiko Lite and Pro
%group inToneKit

%hook TKTonePickerController

// Generates filename, PID and GUID needed to import ringtone
%new
- (NSString *)JFTH_RandomizedRingtoneParameter:(JFTHRingtoneParameterType)Type {
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

- (id)_loadTonesFromPlistNamed:(id)arg1 {
	NSLog(@"DEBUG: _loadTonesFromPlistNamed arg1=%@", arg1);
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];

    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier: @"com.908.AudikoFree"];

    if ([arg1 isEqualToString:@"TKRingtones"]) {
        HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        HUD.detailTextLabel.text = @"0% Complete";
        HUD.textLabel.text = @"Importing Ringtones";
        [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        [HUD setProgress:0.0f animated:NO];
        
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        NSString *newDirectory = @"/var/mobile/Media/iTunes_Control/Ringtones";
        NSError *appDirError;
        NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:oldDirectory error:&appDirError];
        if (appDirFiles)
        {
            NSInteger fileCount = [appDirFiles count];
            double progress = 95.0/fileCount;
            // Get all the files at application documents folder
            //TODO: List folders for multiple applications, if they exist
            
            for (NSString *appDirFile in appDirFiles) 
            { 
                if ([[appDirFile pathExtension] isEqualToString: @"m4r"]) 
                {
                    NSLog(@"Copying to path (%@) with extension (%@)",newDirectory,[appDirFile pathExtension]);
                    NSError *error;
                    NSString *newFile = [[self JFTH_RandomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];
                    if ([localFileManager copyItemAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]
                                toPath:[newDirectory stringByAppendingPathComponent:newFile]
                                error:&error]) 
                    {
                        NSLog(@"File copy success: %@",appDirFile);
                        //Plist data
                        NSString *guid = [self JFTH_RandomizedRingtoneParameter:JFTHRingtoneGUID];
                        long long pid = [[self JFTH_RandomizedRingtoneParameter:JFTHRingtonePID] longLongValue];

                    } else {
                        NSLog(@"File copy (%@) failed: %@",appDirFile,error);
                    }
                    [HUD setProgress:progress animated:NO];
                    progress += 95.0/fileCount;
                }
            }
        }
        [HUD setProgress:0.95f animated:YES];
        HUD.textLabel.text = @"Loading Ringtones";


        // Enumerate ringtones in ringtones folder and add to return dictionary
        NSDictionary *original = %orig;
		NSLog(@"orig = %@", original);
        NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
        NSMutableArray *classicRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"classic"]];
        NSMutableArray *modernRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"modern"]];
        
        NSString *tonesDirectory = @"/Library/Ringtones";
        NSDirectoryEnumerator *dirEnum  = [localFileManager enumeratorAtPath:tonesDirectory];
        NSArray *systemToneFiles = [dirEnum allObjects];
        
        while (NSString *file in systemToneFiles)
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
        return allRingtones;
        
    } else {
        [HUD dismissAfterDelay:0.3];
        return %orig;
    }
}

%end

%end

#define XPCObjects "/System/Library/PrivateFrameworks/ToneKit.framework/ToneKit"

%ctor {
    if (![[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.mobilesafari"]) {
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
    }
}