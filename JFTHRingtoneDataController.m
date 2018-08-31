#import "JFTHRingtoneDataController.h"

#import "JFTHCommonHeaders.h"
#import "JFTHiTunesRingtoneData.h"
#import "JFTHRingtone.h"
#import "FileHash.h"

NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/ToneHelper/ToneHelperData.plist";

@interface JFTHRingtoneDataController () {
    NSMutableSet<JFTHRingtone *> *_importedRingtonesSet;
    
    HBPreferences *preferences;
}

@end

extern NSString *const HBPreferencesDidChangeNotification;

@implementation JFTHRingtoneDataController

#pragma mark - Init methods
- (instancetype)init {
    DDLogWarn(@"{\"Preferences\":\"Initializing222\"}");
    if (self = [super init]) {
        if (!preferences) {
            preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
            DDLogWarn(@"{\"Preferences\":\"Initializing preferences in datacontroller.\"}");
        }
        
        [self _loadImportedRingtones];
        
        // if plist exists, migrate settings from old version!
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if ([localFileManager fileExistsAtPath:TONEHELPERDATA_PLIST_PATH]) {
            DDLogWarn(@"{\"First run\":\"Tweak plist exists, run firstrun again and migrate settings\"}");
            [self migratePlistData];
        }
        DDLogInfo(@"{\"General\":\"Initialized data controller\"}");
    }
    return self;
}

- (void)migratePlistData { // TODO: Add check so we dont get duplicates
    DDLogInfo(@"{\"Plist Migration\":\"Migrating plist data to preferences\"}");
    NSError *readError;
    NSData *plistData = [NSData dataWithContentsOfFile:TONEHELPERDATA_PLIST_PATH options:0 error:&readError];
    if (plistData) { //if plist exists, read it
        NSError *serError;
        NSDictionary *tweakPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                                          options:NSPropertyListMutableContainers
                                                                                           format:nil error:&serError];
        if (tweakPlist) {
            NSDictionary *ringtones = [tweakPlist objectForKey:@"Ringtones"];
            DDLogInfo(@"{\"Plist Migration\":\"Found tones to migrate\"}");
            
            for (NSString *file in ringtones) {
                NSDictionary *curTone = [ringtones objectForKey:file];
                if ([self isImportedRingtoneWithName:[curTone objectForKey:@"Name"]]) {
                    DDLogDebug(@"{\"Plist Migration\":\"Tone is already migrated %@\"}", file);
                    continue;
                }
                
                DDLogInfo(@"{\"Plist Migration\":\"Migrating tone: %@\"}", curTone);
                DDLogDebug(@"{\"Plist Migration\":\"Tone has filename %@\"}", file);
                
                JFTHRingtone *tone = [[JFTHRingtone alloc] initWithName:[curTone objectForKey:@"Name"]
                                                               fileName:file
                                                                    md5:[curTone objectForKey:@"Hash"]
                                                            oldFileName:[curTone objectForKey:@"OldFileName"]
                                                               bundleID:[curTone objectForKey:@"ImportedFromBundleID"]
                                                                    pid:[[curTone objectForKey:@"PID"] longLongValue]
                                                                   guid:[curTone objectForKey:@"GUID"]];
                
                DDLogInfo(@"{\"Plist Migration\":\"Adding tone: %@\"}", tone);
                
                [self addRingtoneToPlist:tone];
            }
            NSError *deleteError;
            NSFileManager *localFileManager = [[NSFileManager alloc] init];
            if (![localFileManager removeItemAtPath:TONEHELPERDATA_PLIST_PATH error:&deleteError]) {
                DDLogError(@"{\"Plist Migration\":\"Failed to delete tweak plist\"}");
            }
        } else {
            DDLogError(@"{\"Plist Migration\":\"Failed to serialize tweak plist: %@\"}",serError);
        }
    } else {
        DDLogError(@"{\"Plist Migration\":\"Failed to read tweak plist: %@\"}", readError);
    }

}
#pragma mark - Imported ringtones array data handling
- (void)_loadImportedRingtones {
    DDLogInfo(@"{\"Preferences\":\"Start loading ringtones from preferences\"}");
    
    // Read ringtones array from preferences
    NSData *importedRingtonesData = [preferences objectForKey:@"Ringtones" default:nil];
    _importedRingtonesSet = nil;
    
    if (importedRingtonesData) {
        DDLogDebug(@"{\"Preferences\":\"Unarchiving ringtone data\"}");
        NSSet *ringtones = [NSKeyedUnarchiver unarchiveObjectWithData:importedRingtonesData];
        if (ringtones) {
            DDLogDebug(@"{\"Preferences\":\"Loaded and unarchived ringtone data: %@\"}", ringtones);
            _importedRingtonesSet = [[NSMutableSet alloc] initWithSet:ringtones];
            return;
        }
    }
    DDLogDebug(@"{\"Preferences\":\"No ringtone data found. Creating new...\"}");
    _importedRingtonesSet = [NSMutableSet set];
}
- (void)_saveImportedRingtones {
    DDLogInfo(@"{\"Preferences\":\"Saving ringtones to preferences\"}");
    
    [preferences setObject:[NSKeyedArchiver archivedDataWithRootObject:_importedRingtonesSet] forKey:@"Ringtones"];
    [preferences synchronize];
}

#pragma mark - Add/Remove ringtones
- (void)addRingtoneWithName:(NSString *)name
                   filePath:(NSString *)filePath
               importedFrom:(NSString *)bundleID {
    // Ringtone needs to have been copied before calling this
    // create ringtone object
    JFTHRingtone *newtone = [[JFTHRingtone alloc] initWithName:name
                                                      filePath:filePath
                                                      bundleID:bundleID];
    
    [self addRingtone:newtone];
}
- (void)addRingtone:(JFTHRingtone *)newtone {
    DDLogDebug(@"{\"Preferences:\":\"Adding ringtone to tweak data: %@\"}", newtone);
    [_importedRingtonesSet addObject:newtone];
    [self _saveImportedRingtones]; // Calling this too often?
}

- (void)deleteRingtoneWithIdentifier:(NSString *)toneIdentifier {
    // Find ringtone
    JFTHRingtone *toneToDelete;
    for (JFTHRingtone *curTone in _importedRingtonesSet) {
        if ([curTone.toneIdentifier isEqualToString:toneIdentifier]) {
            
            toneToDelete = curTone;
            DDLogInfo(@"{\"Preferences:\":\"Found tone to delete: %@\"}", curTone.name);
            break; // i only want one...
        }
    }
    // Delete it if found
    DDLogDebug(@"{\"Ringtone info\":\"Deleting ringtone from: %@\"}", toneToDelete.name);
    [_importedRingtonesSet removeObject:toneToDelete];
    [self _saveImportedRingtones];
    DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones: %@\"}", _importedRingtonesSet);
}
#pragma mark - Ringtone checks
- (BOOL)isImportedRingtoneWithName:(NSString *)name {
    NSArray *names = [_importedRingtonesSet valueForKey:@"name"];
    
    DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone list: %@\"}", names);
    DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ resukt:%d\"}", name, [names containsObject:name]);
    
    return [names containsObject:name];
}
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash { //TODO: See JFTHRingtone todo about md5
    NSArray *hashes = [_importedRingtonesSet valueForKey:@"md5"];
    
    DDLogVerbose(@"{\"Ringtone Checks\":\"Got ringtone md5 list: %@\"}", hashes);
    DDLogVerbose(@"{\"Ringtone Checks\":\"Comparing with: %@ resukt:%d\"}", hash, [hashes containsObject:hash]);
    
    return [hashes containsObject:hash];
}

@end
