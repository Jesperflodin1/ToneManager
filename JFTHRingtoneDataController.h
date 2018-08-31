
#import <Foundation/Foundation.h>
#import <Cephei/HBPreferences.h>

@class JFTHRingtone;

@interface JFTHRingtoneDataController : NSObject

@property (nonatomic, copy) NSMutableArray *ringtones;

- (void)_migratePlistData;

- (void)_saveRingtonesData;

- (void)addRingtoneWithName:(NSString *)name
                   filePath:(NSString *)filePath
               importedFrom:(NSString *)bundleID;
- (void)addRingtone:(JFTHRingtone *)newtone;
- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash;

@end
