#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController;

@interface JFTHRingtoneScanner : NSObject {
}

@property (nonatomic) int importedCount;
@property (nonatomic) JFTHRingtoneDataController *ringtoneDataController;

// Uses documents folder in each app

- (void)importNewRingtonesFromSubfoldersInApps:(NSDictionary *)apps;

- (void)_getNewRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)subfolder;

- (BOOL)_shouldImportRingtones;

- (void)_importNewRingtones;



@end
