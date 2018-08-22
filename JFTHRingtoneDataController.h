
#import "JFTHHeaders.h"
#import "JFTHRingtoneImporter.h"


typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};



@interface JFTHRingtoneDataController : NSObject {
    
}

@property (nonatomic) BOOL shouldWriteITunesRingtonePlist;

- (void)saveRingtonesPlist;
- (BOOL)loadRingtonesPlist;

- (BOOL)enableITunesRingtonePlistEditing;
- (void)removeDuplicatesInItunesPlistOf:(NSString *)name;

- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName oldFileName:(NSString *)oldFile importedFrom:(NSString *)bundleID hash:(NSString *)md5;
- (void)deleteRingtoneWithGUID:(NSString *)guid;
//- (NSDictionary *)getRingtoneWithFilename:(NSString *)filename;
- (NSDictionary *)getRingtoneWithName:(NSString *)name;
- (NSDictionary *)getRingtoneWithHash:(NSString *)md5;
- (NSDictionary *)getITunesRingtoneWithGUID:(NSString *)guid;
- (NSDictionary *)getITunesRingtoneWithName:(NSString *)name;

- (void)loadTweakPlist;
- (void)saveTweakPlist;
- (void)save;

- (NSDictionary *)getItunesRingtones;
- (NSDictionary *)getImportedRingtones;

- (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;

+ (void)syncPlists:(BOOL)currentITunesWriteStatus;
- (void)deleteRingtoneFromITunesPlist:(NSString *)file;
- (void)addRingtoneToITunesPlist:(NSDictionary *)tone fileName:(NSString *)file;

- (void)firstRun;

@end