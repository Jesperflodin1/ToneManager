
#import <Foundation/Foundation.h>

#import "iOSHeaders/TLToneManager.h"

@class JFTHRingtoneInstaller;

@interface JFTHRingtoneDataController : NSObject {
    TLToneManager *_toneManager;
}

@property (nonatomic, readonly) TLToneManager *toneManager;
@property (nonatomic) NSMutableArray<NSDictionary *> *ringtones;
@property (nonatomic, weak) JFTHRingtoneInstaller *installer;

@property (nonatomic) NSMutableArray<NSDictionary *> *ringtonesToImport;

- (NSMutableArray *)ringtones;

- (void)startImport;
- (void)importNextTone;
- (void)saveMetaData;
- (void)_addRingtone:(NSDictionary *)newTone;
- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier;

- (void)importTone:(NSString *)filePath fromBundleID:(NSString *)bundleID toneName:( NSString * _Nullable )toneName;

- (BOOL)isImportedRingtoneWithName:(NSString *)name;
- (BOOL)isImportedRingtoneWithFilePath:(NSString *)filePath;

- (void)verifyAllToneIdentifiers;

+ (Class __nullable)toneManagerClass;
- (TLToneManager *)toneManager;
+ (BOOL)canImport;

+ (NSString *)createNameFromFile:(NSString *)file;
+ (int)totalTimeForRingtoneFilePath:(NSString *)filePath;

@end
