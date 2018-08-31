
#import <Foundation/Foundation.h>
#import <Cephei/HBPreferences.h>

@class JFTHRingtone;

@interface JFTHRingtoneDataController : NSObject {

}

- (void)migratePlistData;

- (void)_loadImportedRingtones;
- (void)_saveImportedRingtones;

- (void)addRingtoneWithName:(NSString *)name
                   filePath:(NSString *)filePath
               importedFrom:(NSString *)bundleID;
- (void)addRingtone:(JFTHRingtone *)newtone;
- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash;

@end
