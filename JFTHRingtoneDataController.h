
#import <Foundation/Foundation.h>

#import "iOSHeaders/TLToneManager.h"

@interface JFTHRingtoneDataController : NSObject {
    TLToneManager *_toneManager;
}

@property (nonatomic, readonly) TLToneManager *toneManager;
@property (nonatomic, copy) NSMutableSet<NSDictionary *> *ringtones;

- (void)_addRingtone:(NSDictionary *)newTone;
- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier;

- (void)importTone:(NSString *)filePath fromBundleID:(NSString *)bundleID;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithFilePath:(NSString *)filePath;
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash;

+ (Class __nullable)toneManagerClass;
+ (BOOL)canImport;

+ (NSString *)createNameFromFile:(NSString *)file;
+ (NSString *)md5ForRingtoneFilePath:(NSString *)filePath;
+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath;

@end
