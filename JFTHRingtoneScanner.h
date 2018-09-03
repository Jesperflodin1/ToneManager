#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController, JFTHRingtoneInstaller;

@interface JFTHRingtoneScanner : NSObject

@property (nonatomic, weak) JFTHRingtoneInstaller *installer;

- (void)importNewRingtonesFromSubfoldersInApps:(NSDictionary *)apps;

- (void)_getNewRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)subfolder;

@end
