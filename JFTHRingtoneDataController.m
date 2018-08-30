#import "JFTHRingtoneDataController.h"

#import "JFTHCommonHeaders.h"
#import "JFTHiTunesRingtoneData.h"
#import "JFTHRingtone.h"
#import "FileHash.h"
#import "JFTHConstants.h"


NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/ToneHelper/ToneHelperData.plist";

@interface JFTHRingtoneDataController () {
    NSMutableSet<JFTHRingtone *> *_importedRingtonesSet;
    JFTHiTunesRingtoneData *_iTunesRingtoneData;
    
    HBPreferences *preferences;
    BOOL kFirstRun;
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
        [preferences registerBool:&kFirstRun default:NO forKey:@"kFirstRun"];
        
        [self loadImportedRingtones];
        
        DDLogInfo(@"{\"Preferences\":\"First run done status: %d\"}",kFirstRun); // YES = first run done
        if (!kFirstRun) {
            [JFTHRingtoneDataController createFolders];
        }
        
        _iTunesRingtoneData = [[JFTHiTunesRingtoneData alloc] init];
        
        self.shouldWriteITunesRingtonePlist = NO;

        if (!kFirstRun) {
            [self firstRun];
        }
        
        // if plist exists, migrate settings from old version!
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if ([localFileManager fileExistsAtPath:TONEHELPERDATA_PLIST_PATH]) {
            DDLogWarn(@"{\"First run\":\"Tweak plist exists, run firstrun again and migrate settings\"}");
            [JFTHRingtoneDataController createFolders];
            [self firstRun];
            [self migratePlistData];
        }

        DDLogInfo(@"{\"General\":\"Initialized data controller\"}");
    }
    return self;
}
#pragma mark - First run methods
- (void)firstRun {
    //fix duplicates in itunes plist
    if (_iTunesRingtoneData.isWritable) {
        NSDictionary *ringtones = [_iTunesRingtoneData itunesRingtones];
        DDLogInfo(@"{\"First run\":\"Reading itunes plist\"}");
        for (NSString *item in ringtones) {
            [_iTunesRingtoneData removeDuplicatesInItunesPlistOf:[[ringtones objectForKey:item] objectForKey:@"Name"]];
        }
        
        // make sure the file exist
        [_iTunesRingtoneData saveRingtonesPlist];
        
        //firstrun done, dont run again
        [preferences setBool:YES forKey:@"kFirstRun"];
    }
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
- (void)loadImportedRingtones {
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
        } else {
            DDLogDebug(@"{\"Preferences\":\"No ringtone data found. Creating new...\"}");
            _importedRingtonesSet = [NSMutableSet set];
        }
    } else {
        DDLogDebug(@"{\"Preferences\":\"No ringtone data found. Creating new...\"}");
        _importedRingtonesSet = [NSMutableSet set];
    }
}
- (void)saveImportedRingtones {
    DDLogInfo(@"{\"Preferences\":\"Saving ringtones to preferences\"}");
    
    [preferences setObject:[NSKeyedArchiver archivedDataWithRootObject:_importedRingtonesSet] forKey:@"Ringtones"];
    [preferences synchronize];
}

#pragma mark - Add/Remove ringtones
- (void)addRingtoneToPlist:(NSString *)name 
                      file:(NSString *)fileName 
               oldFileName:(NSString *)oldFile 
              importedFrom:(NSString *)bundleID {
    // Ringtone needs to have been copied before calling this
    // create ringtone object
    JFTHRingtone *newtone = [[JFTHRingtone alloc] initWithName:name
                                                      fileName:fileName
                                                   oldFileName:oldFile
                                                      bundleID:bundleID];
    
    [self addRingtoneToPlist:newtone];
}
- (void)addRingtoneToPlist:(JFTHRingtone *)newtone {
    DDLogDebug(@"{\"Preferences:\":\"Adding ringtone to tweak data: %@\"}", newtone);
    [_importedRingtonesSet addObject:newtone];
    [self saveImportedRingtones]; // Calling this too often?
    
    if (self.shouldWriteITunesRingtonePlist && _iTunesRingtoneData.isWritable) {
        
        DDLogDebug(@"{\"iTunes plist:\":\"Adding ringtone to itunes plist: %@\"}", newtone);
        [_iTunesRingtoneData addRingtoneToITunesPlist:[newtone iTunesPlistRepresentation] fileName:[newtone fileName]];
        
    }
}

- (void)deleteRingtoneWithGUID:(NSString *)toneGUID {
    // Find ringtone
    JFTHRingtone *toneToDelete;
    for (JFTHRingtone *curTone in _importedRingtonesSet) {
        if ([curTone.guid isEqualToString:toneGUID]) {
            
            toneToDelete = curTone;
            DDLogInfo(@"{\"Preferences:\":\"Found tone to delete: %@\"}", curTone.name);
        }
    }
    // Delete it if found
    if (toneToDelete) {
        NSError *error;
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if ([localFileManager removeItemAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:toneToDelete.fileName] error:&error]) {
            
            [_importedRingtonesSet removeObject:toneToDelete];
            [self saveImportedRingtones];
            
            DDLogDebug(@"{\"Ringtone info\":\"Deleting ringtone from filesystem: %@\"}", toneToDelete.fileName);
            DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones: %@\"}", _importedRingtonesSet);
        } else {
            DDLogError(@"{\"Ringtone info\":\"Failed to delete ringtone with error: %@\"}", error);
            return;
        }
    }
    
    //Also try to delete from itunes plist
    if (self.shouldWriteITunesRingtonePlist && _iTunesRingtoneData.isWritable && (toneToDelete)) {
        // has permission to write and write access and tone was deleted
        [_iTunesRingtoneData deleteRingtoneFromITunesPlist:[toneToDelete fileName]];
    }
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
- (BOOL)isITunesRingtoneWithName:(NSString *)name {
    if ([_iTunesRingtoneData getITunesRingtoneWithName:name]) {
        DDLogVerbose(@"{\"Ringtone Checks\":\"Is itunes ringtone: %@\"}", name);
        return YES;
    } else {
        return NO;
    }
}

#pragma mark - iTunes plist methods
- (BOOL)enableITunesRingtonePlistEditing {
    if (_iTunesRingtoneData.isWritable) {
        self.shouldWriteITunesRingtonePlist = YES;
        DDLogDebug(@"{\"iTunes plist:\":\"shouldWriteITunesRingtonePlist = %d\"}",self.shouldWriteITunesRingtonePlist);
        return YES;
    } else {
        DDLogDebug(@"{\"iTunes plist:\":\"plist is not writable\"}");
        self.shouldWriteITunesRingtonePlist = NO;
        return NO;
    }
}
- (void)disableiTunesRingtonePlistEditing {
    self.shouldWriteITunesRingtonePlist = NO;
}

- (void)syncPlists:(BOOL)currentITunesWriteStatus {
    DDLogInfo(@"{\"iTunes plist sync\":\"Syncing plists with currentITunesWriteStatus = %d\"}",currentITunesWriteStatus);
    
    if ([self enableITunesRingtonePlistEditing]) {

        for (JFTHRingtone *curTone in _importedRingtonesSet) {

            if ([_iTunesRingtoneData getITunesRingtoneWithGUID:[curTone guid]]) {
                // this ringtone exists in itunes plist
                
                if (!currentITunesWriteStatus) {
                    
                    // and it should not exist there
                    DDLogDebug(@"{\"iTunes plist sync\":\"Deleting ringtone from itunes plist: %@\"}",curTone);
                    [_iTunesRingtoneData deleteRingtoneFromITunesPlist:[curTone fileName]];
                    
                }
            } else if (currentITunesWriteStatus) {
                // does not exist in itunes plist and it should exist there. Add it

                DDLogDebug(@"Adding ringtone to itunes plist: %@",curTone);
                // Add entry to nsmutabledict (plist)
                [_iTunesRingtoneData addRingtoneToITunesPlist:[curTone iTunesPlistRepresentation] fileName:[curTone fileName]];
            }
        }
    }
    [self disableiTunesRingtonePlistEditing];
}

+ (void)createFolders {
    DDLogDebug(@"{\"Foldercreator\":\"Preparing folders\"}");
    
    NSError *dirError;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/iTunes/"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&dirError]) {
        DDLogError(@"{\"Foldercreator\":\"Error creating ringtones folder: %@\"}",dirError);
    } else
        DDLogDebug(@"{\"Foldercreator\":\"Success itunes folder\"}");
    
    NSError *ITdirError;
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/Ringtones"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&ITdirError]) {
        DDLogError(@"{\"Foldercreator\":\"Error creating Ringtone folder:%@\"}",ITdirError);
    } else
        DDLogDebug(@"{\"Foldercreator\":\"Success ringtones folder\"}");
    
    DDLogVerbose(@"{\"Foldercreator\":\"Firstrun done\"}");
}

@end
