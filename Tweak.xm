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

%hook TKTonePickerViewController

-(void)viewDidLoad {
    NSLog(@"DEBUG: viewDidLoad in TKTonePickerViewController");
	/*JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
	HUD.textLabel.text = @"Loading ToneHelper Loading ToneHelper Loading ToneHelper Loading ToneHelper Loading ToneHelper";
	[HUD showInView:self.view];
	[HUD dismissAfterDelay:3.0];*/
}

%end

%hook TKTonePickerController

- (id)_loadTonesFromPlistNamed:(id)arg1 {
	NSLog(@"DEBUG: _loadTonesFromPlistNamed arg1=%@", arg1);
    JGProgressHUD *HUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];

    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier: @"com.908.AudikoFree"];

    if ([arg1 isEqualToString:@"TKRingtones"]) {
        HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        HUD.detailTextLabel.text = @"0% Complete";
        
        HUD.textLabel.text = @"Loading";
        [HUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        [HUD setProgress:0.2f animated:YES];

        NSError *error;
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        NSString *newDirectory = @"/Library/Application Support/ToneHelper/Ringtones/";
        NSFileManager *fm = [NSFileManager defaultManager];

        // Get all the files at ~/Documents/user
        NSArray *files = [fm contentsOfDirectoryAtPath:oldDirectory error:&error];

        for (NSString *file in files) {
            NSLog(@"Copying to path (%@) with extension (%@)",newDirectory,[file pathExtension]);
            if ([[file pathExtension] isEqualToString: @"m4r"]) {
            BOOL success = [fm copyItemAtPath:[oldDirectory stringByAppendingPathComponent:file]
                        toPath:[newDirectory stringByAppendingPathComponent:file]
                        error:&error];
            if (!success)
                NSLog(@"File copy (%@) failed: %@",file,error);
            else 
                NSLog(@"File copy success: %@",file);
            }
        }
        [HUD setProgress:0.7f animated:YES];

        // Enumerate ringtones in ringtones folder and add to return dictionary
        NSDictionary *original = %orig;
		NSLog(@"orig = %@", original);
        NSMutableDictionary *allRingtones = [NSMutableDictionary dictionary];
        NSMutableArray *classicRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"classic"]];
        NSMutableArray *modernRingtones = [NSMutableArray arrayWithArray:[original objectForKey:@"modern"]];
        
        NSString *tonesDirectory = @"/Library/Ringtones";
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        NSDirectoryEnumerator *dirEnum  = [localFileManager enumeratorAtPath:tonesDirectory];
        
        NSString *file;
        while ((file = [dirEnum nextObject]))
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
        [HUD dismissAfterDelay:1.0];
        return allRingtones;
        
    } else {
        [HUD dismissAfterDelay:1.0];
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
            NSLog(@"DEBUG: ToneHelper not initializing...");
    }
}