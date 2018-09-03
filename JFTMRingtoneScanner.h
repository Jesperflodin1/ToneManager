#import <Foundation/Foundation.h>

@class JFTMRingtoneDataController, JFTMRingtoneInstaller;

@interface JFTMRingtoneScanner : NSObject

@property (nonatomic, weak) JFTMRingtoneInstaller *installer;

- (void)importNewRingtonesFromSubfoldersInApps:(NSDictionary *)apps;

- (void)_getNewRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)subfolder;

@end
