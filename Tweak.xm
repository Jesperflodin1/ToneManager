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
%group tonehelpermain
/*
%hook TKTonePickerViewController

-(void)viewDidLoad {
	JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
	HUD.textLabel.text = @"Loading ToneHelper Loading ToneHelper Loading ToneHelper Loading ToneHelper Loading ToneHelper";
	[HUD showInView:self.view];
	[HUD dismissAfterDelay:3.0];
}

%end*/

%hook TKTonePickerController

- (id)_loadTonesFromPlistNamed:(id)arg1 {
	NSLog(@"DEBUG: _loadTonesFromPlistNamed arg1=%@", arg1);
	JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
	HUD.textLabel.text = @"Loading ToneHelper Loading ToneHelper Loading ToneHelper Loading ToneHelper Loading ToneHelper";
	//NSLog(@"DEBUG: %@",);
	//[HUD showInView:[[self delegate] tableView]];
	//[HUD dismissAfterDelay:3.0];

    if ([arg1 isEqualToString:@"TKRingtones"]) {
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
        
        return allRingtones;
        
    } else {
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
            %init(tonehelpermain);
        } else
			NSLog(@"DEBUG: ToneHelper not initializing...");
    }
}