#import "JFTMRingtoneDataController.h"
#import "JFTMRingtoneInstaller.h"
#import "JFTMCommonHeaders.h"
#import <AVFoundation/AVAsset.h>

//NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/ToneHelper/ToneHelperData.plist";

@interface JFTMRingtoneDataController () {
    HBPreferences *preferences;
}

@end

@implementation JFTMRingtoneDataController

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        DDLogDebug(@"{\"Preferences\":\"Initializing preferences in datacontroller.\"}");
        [preferences synchronize];
        self.ringtones = [preferences objectForKey:@"Ringtones" default:[NSMutableArray array]];
        [preferences synchronize];
        
        DDLogDebug(@"{\"Preferences\":\"Got these ringtones from prefs: %@.\"}", _ringtones);
        _toneManager = nil;
        _ringtonesToImport = [NSMutableArray array];
        
        [self verifyAllToneIdentifiers];
        // TODO: Migration
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
#pragma mark - Getters
- (NSMutableArray *)ringtones {
    @synchronized(self) {
        //[preferences synchronize];
        //_ringtones = [preferences objectForKey:@"Ringtones" default:[NSMutableArray array]];
        return [_ringtones mutableCopy];
    }
}

#pragma mark - Adding ringtone
- (void)startImport {
    NSDictionary *tone = [_ringtonesToImport firstObject];
    [self importTone:[tone objectForKey:@"FullPath"] fromBundleID:[tone objectForKey:@"BundleID"] toneName:[tone objectForKey:@"Name"]];
    [_ringtonesToImport removeObject:tone];
}
- (void)importNextTone {
    if ([_ringtonesToImport count] > 0) {
        DDLogDebug(@"{\"Ringtone Import\":\"Import done, calling import for next tone.\"}");
        NSDictionary *tone = [_ringtonesToImport firstObject];
        [self importTone:[tone objectForKey:@"FullPath"] fromBundleID:[tone objectForKey:@"BundleID"] toneName:[tone objectForKey:@"Name"]];
        [_ringtonesToImport removeObject:tone];
    } else {
        DDLogDebug(@"{\"Ringtone Import\":\"Import done, no more tones left to import. Calling saveMetaData\"}");
        [self saveMetaData];
    }
}
- (void)saveMetaData {
    DDLogDebug(@"{\"Preferences\":\"Saving ringtones to preferences\"}");
    @synchronized(self) {
        [preferences synchronize];
        [preferences setObject:self.ringtones forKey:@"Ringtones"];
        [preferences synchronize];
    }
}

// called from completionblock
- (void)_addRingtone:(NSDictionary *)newTone {
    DDLogVerbose(@"{\"Ringtone Import\":\"addRingtone called, newTone=%@\"}",newTone);
    if ([newTone objectForKey:@"Identifier"]) { // Existing identifier is required for import
        @synchronized(self) {
            DDLogDebug(@"{\"Preferences:\":\"Adding ringtone to tweak data: %@\"}", newTone);
            NSMutableArray *allTones = self.ringtones;
            [allTones addObject:newTone];
            self.ringtones = allTones;
            
            [self importNextTone];
        }
    } else
        DDLogWarn(@"{\"Ringtone import\":\"Identifier missing for: %@\"}", newTone);
}
- (void)importTone:(NSString *)filePath fromBundleID:(NSString *)bundleID toneName:( NSString * _Nullable )toneName {
    DDLogInfo(@"{\"Ringtone Import\":\"Trying to import, current tones: %@\"}",_ringtones);
    if (self.toneManager) {
        NSString *fileName = [[filePath lastPathComponent] stringByDeletingPathExtension];
        NSString *name;
        if (toneName)
            name = toneName;
        else
            name = [JFTMRingtoneDataController createNameFromFile:fileName];
        
        NSMutableDictionary *currentTone = [NSMutableDictionary dictionary];
        [currentTone setObject:name forKey:@"Name"];
        [currentTone setObject:[NSNumber numberWithInt:[JFTMRingtoneDataController totalTimeForRingtoneFilePath:filePath]] forKey:@"Total Time"];
        [currentTone setObject:@NO forKey:@"Purchased"];
        [currentTone setObject:@NO forKey:@"Protected Content"];
        
        NSMutableDictionary *localMetaData = [[NSMutableDictionary alloc] initWithDictionary:currentTone];
        [localMetaData setObject:filePath forKey:@"Filepath"];
        [localMetaData setObject:bundleID forKey:@"Imported From"];
        
        NSData *toneData = [NSData dataWithContentsOfFile:filePath];
        
        __block NSMutableDictionary *metaData = [localMetaData mutableCopy];
        
        void (^importCompleteBlock)(BOOL success, NSString *toneIdentifier) =^(BOOL success, NSString *toneIdentifier) {
            if (success && (toneIdentifier)) {
                DDLogWarn(@"{\"Ringtone Import\":\"Ringtone import success in completionblock, got identifier: %@\"}", toneIdentifier);

                [metaData setValue:toneIdentifier forKey:@"Identifier"];
                [self _addRingtone:metaData];
            } else {
                DDLogWarn(@"{\"Ringtone Import\":\"Ringtone import failed because success=0\"}");
            }
        };
        DDLogInfo(@"{\"Ringtone Import\":\"Calling import for tone with metadata: %@\"}", currentTone);
        @synchronized(self) {
            DDLogVerbose(@"{\"Ringtone Import\":\"Trying to import with toneData: %@\"}",toneData);
            DDLogVerbose(@"{\"Ringtone Import\":\"Trying to import with metadata: %@\"}",currentTone);
            [self.toneManager importTone:toneData metadata:currentTone completionBlock:importCompleteBlock];
        }
    
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
        NSMutableArray *allTones = self.ringtones;
        for (NSDictionary *curTone in allTones) {
            if ([[curTone objectForKey:@"Identifier"] isEqualToString:toneIdentifier]) {
                
                toneToDelete = curTone;
                DDLogInfo(@"{\"Preferences:\":\"Found tone to delete: %@\"}", toneToDelete);
                break; // i only want one...
            }
        }
        // Delete it if found
        [allTones removeObject:toneToDelete];
        self.ringtones = allTones;
        [preferences setObject:allTones forKey:@"Ringtones"];
        [preferences synchronize];
        DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones: %@\"}", _ringtones);
    }
}
#pragma mark - Ringtone checks

- (BOOL)isImportedRingtoneWithName:(NSString *)name {
    [self verifyAllToneIdentifiers];
    NSSet *names = [NSSet setWithArray:[self.ringtones valueForKey:@"Name"]];
    
    DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone list: %@\"}", names);
    DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ result:%d\"}", name, [names containsObject:name]);
    
    return [names containsObject:name];
}
- (BOOL)isImportedRingtoneWithFilePath:(NSString *)filePath {
    [self verifyAllToneIdentifiers];
    NSSet *filepaths = [NSSet setWithArray:[self.ringtones valueForKey:@"Filepath"]];
    
    DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone list: %@\"}", filepaths);
    DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ result:%d\"}", filePath, [filepaths containsObject:filePath]);
    
    return [filepaths containsObject:filePath];
}

- (void)verifyAllToneIdentifiers { // Wow, this got ugly...
    @synchronized(self) {
        DDLogDebug(@"{\"Ringtone Checks\":\"Starting tone identifier verification with ringtones: %@\"}",_ringtones);
        NSMutableArray *identifiers = [_ringtones valueForKey:@"Identifier"];
        
        if ([identifiers count] > 0) {
            //we have identifiers, verify them
            DDLogVerbose(@"{\"Ringtone Checks\":\"Found identifiers to verify: %@\"}", identifiers);
            TLToneManager *localToneManager = self.toneManager;
            if (localToneManager) {
                
                NSMutableArray *allTones = [_ringtones mutableCopy];
                
                
                
                
                for (NSString *identifier in identifiers) {
                    if ([identifier isEqual:[NSNull null]]) // skip nonexistent identifiers
                        break;
                    DDLogVerbose(@"{\"Ringtone Checks\":\"Verifying identifier: %@\"}", identifier);
                    if (![localToneManager toneWithIdentifierIsValid:identifier]) {
                        // Toneidentifier is invalid, remove it from local data.
                        DDLogVerbose(@"{\"Ringtone Checks\":\"Identifier is invalid: %@\"}", identifier);
                        NSDictionary *toneToDelete = nil;
                        
                        for (NSDictionary *curTone in allTones) {

                            if ([[curTone objectForKey:@"Identifier"] isEqualToString:identifier]) {
                                
                                toneToDelete = curTone;
                                DDLogInfo(@"{\"Preferences:\":\"Found tone to delete because identifier is invalid: %@\"}", toneToDelete);
                                break; // i only want one...
                            }
                        }
                        // Delete it if found
                        if (toneToDelete)
                            [allTones removeObject:toneToDelete];
                    }
                }
                
                // done, save resulting nsarray
                [preferences setObject:allTones forKey:@"Ringtones"];
                [preferences synchronize];
            } else {
                DDLogError(@"{\"Ringtone Checks\":\"Ringtone verification failed, tonemanager failed to load\"}");
            }
        }
    }
}

#pragma mark - TLToneManager methods
- (TLToneManager *)toneManager {
    if (!_toneManager) {
        Class toneMan = [JFTMRingtoneDataController toneManagerClass];
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
+ (int)totalTimeForRingtoneFilePath:(NSString *)filePath {
    CMTime duration = [AVAsset assetWithURL:[NSURL URLWithString:filePath]].duration;
    return (int)( CMTimeGetSeconds(CMTimeAbsoluteValue(duration)) * 1000);
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
