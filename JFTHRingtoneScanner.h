#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController;

@interface JFTHRingtoneScanner : NSObject

//@property (nonatomic) int importedCount;

- (void)importNewRingtonesFromSubfoldersInApps:(NSDictionary *)apps;

- (void)_getNewRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)subfolder;



@end
