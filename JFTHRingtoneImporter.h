#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController;

@interface JFTHRingtoneImporter : NSObject {
}

@property (nonatomic) int importedCount;
@property (nonatomic, retain) JFTHRingtoneDataController *ringtoneDataController;

- (void)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default

- (BOOL)shouldImportRingtones;

- (void)importNewRingtones;



@end
