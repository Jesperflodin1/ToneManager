
#import <Foundation/Foundation.h>


typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};



@interface JFTHRingtoneDataController : NSObject {
    
}
- (void)saveRingtonesPlist;
- (void)loadRingtonesPlist;

- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName oldFileName:(NSString *)oldFile importedFrom:(NSString *)bundleID hash:(NSString *)md5;
- (void)deleteRingtoneWithFilename:(NSString *)filename;
//- (NSDictionary *)getRingtoneWithFilename:(NSString *)filename;
- (NSDictionary *)getRingtoneWithName:(NSString *)name;
- (NSDictionary *)getRingtoneWithHash:(NSString *)md5;

- (void)loadTweakPlist;
- (void)saveTweakPlist;
- (void)save;

- (NSDictionary *)getItunesRingtones;
- (NSDictionary *)getImportedRingtones;

- (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;

@end