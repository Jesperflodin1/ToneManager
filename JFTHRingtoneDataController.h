
#import <Foundation/Foundation.h>

@class JFTHRingtone;

@interface JFTHRingtoneDataController : NSObject {
    
}

@property (nonatomic) BOOL shouldWriteITunesRingtonePlist;

- (void)migratePlistData;
- (BOOL)enableITunesRingtonePlistEditing;

- (void)loadImportedRingtones;
- (void)saveImportedRingtones;

- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName oldFileName:(NSString *)oldFile importedFrom:(NSString *)bundleID;
- (void)addRingtoneToPlist:(JFTHRingtone *)newtone;
- (void)deleteRingtoneWithGUID:(NSString *)guid;

- (NSDictionary *)importedTones;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isITunesRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash;

- (void)syncPlists:(BOOL)currentITunesWriteStatus;

+ (void)createFolders;

@end
