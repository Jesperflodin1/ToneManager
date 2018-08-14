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
+ (NSArray *)getRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)folder {
    // TODO: Get apps from preferences. Check if app exist and if folder exists.
    FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:folder];
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    if (appDirFiles) {
        return appDirFiles;
    } else {
        return nil; //Application unavailable (or documents folder non-existent)
    }
}
+ (NSArray *)getRingtoneFilesFromApp:(NSString *)bundleID {
    return [JFTHRingtoneImporter getRingtoneFilesFromApp:bundleID withSubfolder:@"Documents"];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initHUD];
    }
    return self;
}
- (void)initHUD {
    self.progressHUD = [[JGProgressHUD alloc] initWithStyle:JGProgressHUDStyleExtraLight];
    self.progressHUD.interactionType = JGProgressHUDInteractionTypeBlockTouchesOnHUDView;
    self.progressHUD.animation = [JGProgressHUDFadeZoomAnimation animation];
    self.progressHUD.vibrancyEnabled = YES;
    self.progressHUD.shadow = [JGProgressHUDShadow shadowWithColor:[UIColor blackColor] offset:CGSizeZero radius:5.0 opacity:0.3f];
}
- (void)showProgressHUD {
    if (!self.progressHUD) {
        [self initHUD];
    }
    self.progressHUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
    self.progressHUD.detailTextLabel.text = @"0% Complete";
    self.progressHUD.textLabel.text = @"Loading";
    [self.progressHUD setProgress:0.0f animated:YES];
    [self.progressHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
}
- (void)showSuccessHUD { //Dismisses itself
    if (!self.progressHUD) {
        [self initHUD];
    }
    self.progressHUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init];
    self.progressHUD.square = YES;
    self.progressHUD.textLabel.text = @"Done";
    [self.progressHUD showInView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
    [self.progressHUD dismissAfterDelay:0.3f animated:YES];
}
- (void)setProgress:(int)p {
    progress = p;
    [self.progressHUD setProgress:progress/100.0f animated:YES];
    self.progressHUD.detailTextLabel.text = [NSString stringWithFormat:@"%d Complete", progress];
}




@end