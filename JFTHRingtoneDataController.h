
#import "JFTHHeaders.h"
#import "JFTHRingtoneData.h"
#import "JFTHiTunesRingtoneData.h"
#import "JFTHUtilities.h"

@interface JFTHRingtoneDataController : NSObject {
    
}

@property (nonatomic) BOOL shouldWriteITunesRingtonePlist;

- (void)migratePlistData;
- (BOOL)enableITunesRingtonePlistEditing;

- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName oldFileName:(NSString *)oldFile importedFrom:(NSString *)bundleID hash:(NSString *)md5;
- (void)addRingtoneToPlist:(JFTHRingtone *)newtone;
- (void)deleteRingtoneWithGUID:(NSString *)guid;

- (NSDictionary *)importedTones;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isITunesRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash;

- (void)syncPlists:(BOOL)currentITunesWriteStatus;

@end
