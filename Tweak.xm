#import "ToneHelper.h"
#import "JGProgressHUD/JGProgressHUD.h"

// TODO: 
// Edit "Add to favorites" and hook its target to send message to springboard when download is finished 
// (perhaps need to hook something else so the message is sent when download is finished)
//
// Edit "Install" button to reflect "installed" status or not if tone not present in library
// - Option to uninstall tone? (Perhaps in a pref bundle?)
// Remove the itunes guide and replace with installation message (uialert?)
//
// Test if spaces in file names will be a problem? (for ringtones)
//
// Make sure to hook correct classes depending on bundle for current app
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
                    NSString *newFile = [self JFTH_RandomizedRingtoneParameter:JFTHRingtoneFileName];
                    if ([localFileManager copyItemAtPath:[oldDirectory stringByAppendingPathComponent:appDirFile]
                                toPath:[newDirectory stringByAppendingPathComponent:newFile]
                                error:&error]) 
                    {
                        NSLog(@"File copy success: %@",appDirFile);
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
/*
%hook SpringBoard
- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    // Add an observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directoryDidChange:) name:@"FilesChanged" object:self];
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier: @"com.908.AudikoFree"]; 
    NSLog(@"Data path: %@", [appInfo.dataContainerURL.path stringByAppendingPath:@"Documents"]);
    mPath = [appInfo.dataContainerURL.path stringByAppendingPath:@"Documents"];

    int fildes = open(mPath.UTF8String, O_RDONLY);

    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);

    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fildes, DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE, queue);

    dispatch_source_set_event_handler(source, ^{
        NSLog(@"DEBUG: Sending event notification");
        [self updateListWithNotification: YES];
    });

    dispatch_source_set_cancel_handler(source, ^{
        close((int)dispatch_source_get_handle(source));
    });

    _source = source;

    dispatch_resume(source); // Start monitoring

    dispatch_async(queue, ^{
        [self updateListWithNotification: NO];
    });
}
- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FilesChanged" object:self];
    dispatch_source_cancel(_source); // Stop monitoring
    %orig;
}
%new
- (void)updateListWithNotification: (BOOL)withNotification
{
    // Our manipulation of state here is OK because we know this only ever gets called on a serial queue
    mFiles = mFiles ?: [NSArray array];

    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: mPath error: nil] ?: [NSArray array];

    if (withNotification)
    {
        NSSet* oldFiles = [NSSet setWithArray: mFiles];
        NSSet* newFiles = [NSSet setWithArray: contents];

        NSMutableSet* addedFiles = [newFiles mutableCopy]; [addedFiles minusSet: oldFiles];
        NSMutableSet* removedFiles = [oldFiles mutableCopy]; [removedFiles minusSet: newFiles];
        NSDictionary* ui = @{ @"FilesRemoved" : removedFiles, @"FilesAdded" : addedFiles };
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName: @"FilesChanged" object: self userInfo: ui];
        });
    }

    mFiles = contents;
}

%new
- (void)directoryDidChange: (NSNotification*)n
{
    NSLog(@"Directory %@ changed.\nFiles removed: %@\nFiles added: %@", mPath, n.userInfo[@"FilesRemoved"], n.userInfo[@"FilesAdded"]);
}
%end*/

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