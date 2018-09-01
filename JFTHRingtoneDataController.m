#import "JFTHRingtoneDataController.h"
#import <Cephei/HBPreferences.h>
#import "JFTHCommonHeaders.h"

NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/ToneHelper/ToneHelperData.plist";

@interface JFTHRingtoneDataController () {
    HBPreferences *preferences;
}

@end

extern NSString *const HBPreferencesDidChangeNotification;

@implementation JFTHRingtoneDataController

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        DDLogDebug(@"{\"Preferences\":\"Initializing preferences in datacontroller.\"}");
        [preferences registerObject:&_ringtones default:[NSMutableSet set] forKey:@"Ringtones"];
        
        //check if all toneidentifiers are valid, if not: remove from set
        
        // if plist exists, migrate settings from old version!
        /*NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if ([localFileManager fileExistsAtPath:TONEHELPERDATA_PLIST_PATH]) {
            DDLogWarn(@"{\"First run\":\"Tweak plist exists, run firstrun again and migrate settings\"}");
            [self _migratePlistData];
        }*/
        DDLogInfo(@"{\"DataController\":\"Initialized data controller\"}");
    }
    return self;
}

#pragma mark - Adding ringtone
- (void)_addRingtone:(NSDictionary *)newTone {
    @synchronized(self) {
        DDLogDebug(@"{\"Preferences:\":\"Adding ringtone to tweak data: %@\"}", newTone);
        NSMutableSet *allTones = [_ringtones mutableCopy];
        [allTones addObject:newTone];
        DDLogDebug(@"{\"Preferences\":\"Saving ringtones to preferences\"}");
        [preferences setObject:allTones forKey:@"Ringtones"];
        [preferences synchronize];
    }
}
- (void)importTone:(NSString *)filePath fromBundleID:(NSString *)bundleID {
    DDLogInfo(@"{\"Ringtone Import\":\"Trying to import, current tones: %@\"}",_ringtones);
    if (self.toneManager) {
        NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
        
        NSDictionary *currentTone = @{
                 @"Name":[JFTHRingtoneDataController createNameFromFile:fileName],
                 @"Total Time":[NSNumber numberWithLong:[JFTHRingtoneDataController totalTimeForRingtoneFilePath:filePath]],
                 @"Purchased":@NO,
                 @"Protected Content":@NO
                 };
        NSMutableDictionary *localMetaData = [[NSMutableDictionary alloc] initWithDictionary:currentTone];
        [localMetaData setObject:filePath forKey:@"Filepath"];
        [localMetaData setObject:[JFTHRingtoneDataController md5ForRingtoneFilePath:filePath] forKey:@"md5"];
        [localMetaData setObject:bundleID forKey:@"Imported From"];
        
        NSData *toneData = [NSData dataWithContentsOfFile:filePath];
        
        void (^importCompleteBlock)(BOOL success, NSString *toneIdentifier) =^(BOOL success, NSString *toneIdentifier) {
            if (!success) {
                DDLogWarn(@"{\"Ringtone Import\":\"Ringtone import failed because success=0\"}");
                return;
            }
            DDLogWarn(@"{\"Ringtone Import\":\"Ringtone import success in completionblock\"}");
            
            [localMetaData setValue:toneIdentifier forKey:@"toneIdentifier"];
            [self _addRingtone:localMetaData];
        };
        DDLogInfo(@"{\"Ringtone Import\":\"Calling import for tone with metadata: %@\"}", currentTone);
        [self.toneManager importTone:toneData metadata:currentTone completionBlock:importCompleteBlock];
    
    } else {
        DDLogWarn(@"{\"Ringtone Import\":\"Ringtone import failed because TLToneManager does not exist...\"}");
        return;
    }
}

#pragma mark - Delete ringtone

- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier {
    // Find ringtone
    @synchronized(self) {
        NSDictionary *toneToDelete;
        NSMutableSet *allTones = [_ringtones mutableCopy];
        for (NSDictionary *curTone in allTones) {
            if ([[curTone objectForKey:@"Identifier"] isEqualToString:toneIdentifier]) {
                
                toneToDelete = curTone;
                DDLogInfo(@"{\"Preferences:\":\"Found tone to delete: %@\"}", toneToDelete);
                break; // i only want one...
            }
        }
        // Delete it if found
        [allTones removeObject:toneToDelete];
        [preferences setObject:allTones forKey:@"Ringtones"];
        [preferences synchronize];
        DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones: %@\"}", _ringtones);
    }
}
#pragma mark - Ringtone checks

- (BOOL)isImportedRingtoneWithName:(NSString *)name {
    @synchronized(self) {
    NSSet *names = [self.ringtones valueForKey:@"Name"];
    
    DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone list: %@\"}", names);
    DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ result:%d\"}", name, [names containsObject:name]);
    
    return [names containsObject:name];
    }
}
- (BOOL)isImportedRingtoneWithFilePath:(NSString *)filePath {
    @synchronized(self) {
        NSSet *filepaths = [self.ringtones valueForKey:@"Filepath"];
        
        DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone list: %@\"}", filepaths);
        DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ result:%d\"}", filePath, [filepaths containsObject:filePath]);
        
        return [filepaths containsObject:filePath];
    }
}
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash { //TODO: See JFTHRingtone todo about md5
    @synchronized(self) {
        NSSet *hashes = [self.ringtones valueForKey:@"md5"];
    
        DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone md5 list: %@\"}", hashes);
        DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ resukt:%d\"}", hash, [hashes containsObject:hash]);
        
        return [hashes containsObject:hash];
    }
}

#pragma mark - Getters
- (TLToneManager *)toneManager {
    if (!_toneManager) {
        Class toneMan = [JFTHRingtoneDataController toneManagerClass];
        if (toneMan) {
            if ([toneMan instancesRespondToSelector:@selector(importTone:metadata:completionBlock:)]) {
                _toneManager = [toneMan new];
            }
        }
    }
    return _toneManager;
}
+ (Class __nullable)toneManagerClass {
    Class toneManager = NSClassFromString(@"TLToneManager");
    if (!toneManager) {
        DDLogInfo(@"{\"DataController\":\"TLToneManager class not found, trying to load framework\"}");
        NSBundle *toneLibraryBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ToneLibrary.framework"];
        if ([toneLibraryBundle isLoaded]) {
            DDLogError(@"{\"DataController\":\"ToneLibrary loaded but no TLToneManager found, something is seriously wrong.\"}");
            toneManager = nil;
        } else {
            DDLogInfo(@"{\"DataController\":\"Loading ToneLibrary bundle\"}");
            if ([toneLibraryBundle loadAndReturnError:nil]) {
                toneManager = NSClassFromString(@"TLToneManager");
            } else {
                DDLogError(@"{\"DataController\":\"Failed to find TLTonemanager class, but i did load the framework...\"}");
                toneManager = nil;
            }
        }
    }
    return toneManager;
}
+ (BOOL)canImport {
    BOOL result;
    Class toneManager;
    if ( (toneManager = [self toneManagerClass]) && ([toneManager instancesRespondToSelector:@selector(importTone:metadata:completionBlock:)]) ) {
        result = [toneManager instancesRespondToSelector:@selector(removeImportedToneWithIdentifier:)];
    } else
        result = NO;
    
    DDLogInfo(@"{\"DataController\":\"Can i import ringtones? (%d)\"}", result);
    return result;
}

#pragma mark - Methods for calculated values
+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath {
    // TODO: CODE
    return 0;
}
+ (NSString *)md5ForRingtoneFilePath:(NSString *)filePath {
    return [FileHash md5HashOfFileAtPath:filePath];
}

+ (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

- (void)dealloc {
    DDLogInfo(@"{\"DataController\":\"Deallocating\"}");
}
@end
