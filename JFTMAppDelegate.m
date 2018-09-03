#import "JFTMAppDelegate.h"
#import "JFTMRootViewController.h"
#import "JFTMCommonHeaders.h"
#import "JFTMRingtoneInstaller.h"

BOOL kTHEnabled;
BOOL kTHDebugLogging;
HBPreferences *preferences;

@implementation JFTMAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	_window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_rootViewController = [[UINavigationController alloc] initWithRootViewController:[[JFTMRootViewController alloc] init]];
	_window.rootViewController = _rootViewController;
	[_window makeKeyAndVisible];
    
    LogglyFields *logglyFields = [[LogglyFields alloc] init];
    [logglyFields setAppversion:@"0.4.2"];
    
    [logglyFields setUserid:[[[UIDevice currentDevice] identifierForVendor] UUIDString]];
    
    LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
    [logglyLogger setLogFormatter:[[LogglyFormatter alloc] initWithLogglyFieldsDelegate:logglyFields]];
    logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
    
    logglyLogger.saveInterval = 600;
    
    preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
    [preferences registerBool:&kTHDebugLogging default:NO forKey:@"kDebugLogging"];
    [preferences registerBool:&kTHEnabled default:NO forKey:@"kEnabled"];
    
    [DDLog addLogger:logglyLogger];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    JFTMRingtoneInstaller *installer = [JFTMRingtoneInstaller new];
    [installer installRingtone:@"/var/mobile/Containers/Data/Application/21EFB592-D000-4CAB-8190-AD2684B8BFF4/Documents/Stiftelsen - Vart jag än går_24770249.m4r"];
}

/*- (void)dealloc {
	[super dealloc];
}*/

@end
