#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController;

@interface JFTHRingtoneScanner : NSObject {
}

@property (nonatomic) int importedCount;
@property (nonatomic, retain) JFTHRingtoneDataController *ringtoneDataController;

// Uses documents folder in each app
- (void)importNewRingtonesFromApps:(NSArray *)apps;

- (BOOL)_shouldImportRingtones;

- (void)_importNewRingtones;



@end
