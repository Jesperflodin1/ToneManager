
#import <Foundation/Foundation.h>
#import <Cephei/HBPreferences.h>

@class JFTHRingtone;

@interface JFTHRingtoneDataController : NSObject {

}

@property (nonatomic) BOOL shouldWriteITunesRingtonePlist;

- (void)migratePlistData;

- (void)loadImportedRingtones;
- (void)saveImportedRingtones;

- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName oldFileName:(NSString *)oldFile importedFrom:(NSString *)bundleID;
- (void)addRingtoneToPlist:(JFTHRingtone *)newtone;
- (void)deleteRingtoneWithGUID:(NSString *)guid;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isITunesRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash;

- (void)syncPlists:(BOOL)currentITunesWriteStatus;
- (BOOL)enableITunesRingtonePlistEditing;
- (void)disableiTunesRingtonePlistEditing;

+ (void)createFolders;

@end
