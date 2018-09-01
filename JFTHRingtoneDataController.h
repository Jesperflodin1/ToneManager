
#import <Foundation/Foundation.h>

#import "iOSHeaders/TLToneManager.h"

@interface JFTHRingtoneDataController : NSObject {
    TLToneManager *_toneManager;
}

@property (nonatomic, readonly) TLToneManager *toneManager;
@property (nonatomic, copy) NSMutableArray<NSDictionary *> *ringtones;

- (void)_addRingtone:(NSDictionary *)newTone;
- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier;

- (void)importTone:(NSString *)filePath fromBundleID:(NSString *)bundleID toneName:( NSString * _Nullable )toneName;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithFilePath:(NSString *)filePath;

+ (Class __nullable)toneManagerClass;
- (TLToneManager *)toneManager;
+ (BOOL)canImport;

+ (NSString *)createNameFromFile:(NSString *)file;
+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath;

@end
