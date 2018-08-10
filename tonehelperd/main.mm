#import "JFToneHelperd.h"

/*static void enable(CFNotificationCenterRef center,
                   void *observer,
                   CFStringRef name,
                   const void *object,
                   CFDictionaryRef userInfo) {
    HBLogDebug(@"ToneHelperd: Enable");
    [[JFToneHelperd sharedInstance] enable];
}

static void disable(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    HBLogDebug(@"ToneHelperd: Disable");
    [[JFToneHelperd sharedInstance] disable];
}

static void refreshPreferences(CFNotificationCenterRef center,
                    void *observer,
                    CFStringRef name,
                    const void *object,
                    CFDictionaryRef userInfo) {
    HBLogDebug(@"ToneHelperd: Refresh");
    [[JFToneHelperd sharedInstance] refreshPreferences];
}*/

int main(int argc, char **argv, char **envp) {
	NSLog(@"ToneHelperd: Launching!");
	FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier: @"com.908.AudikoFree"]; 
    JFToneHelperd *audikoMonitor = [[JFToneHelperd alloc] initWithURL:
		[appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"]
	];
	[audikoMonitor enable];
    /*CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    enable,
                                    CFSTR("fi.flodin.tonehelperd.enable"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    disable,
                                    CFSTR("fi.flodin.tonehelperd.disable"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    NULL,
                                    refreshPreferences,
                                    CFSTR("fi.flodin.tonehelperd.refreshPreferences"),
                                    NULL,
                                    CFNotificationSuspensionBehaviorCoalesce);*/
    CFRunLoopRun();
	return 0;
}

// vim:ft=objc
