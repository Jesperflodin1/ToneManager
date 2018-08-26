#import "JFTHRingtoneDataController.h"

NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/ToneHelper/ToneHelperData.plist";

@interface JFTHRingtoneDataController () {
    JFTHRingtoneData *_importedTonesData;
    JFTHiTunesRingtoneData *_iTunesRingtoneData;
}

@end

BOOL kFirstRun;

extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;

@implementation JFTHRingtoneDataController

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kFirstRun default:NO forKey:@"kFirstRun"];
        
        DDLogInfo(@"{\"Preference\":\"First run done status: %d\"}",kFirstRun); // YES = first run done
        if (!kFirstRun) {
            [JFTHUtilities createFolders];
        }
        
        _importedTonesData = [[JFTHRingtoneData alloc] init];
        _iTunesRingtoneData = [[JFTHiTunesRingtoneData alloc] init];
        
        self.shouldWriteITunesRingtonePlist = NO;

        if (!kFirstRun) {
            [self firstRun];
        }
        
        // if plist exists, migrate settings!
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if ([localFileManager fileExistsAtPath:TONEHELPERDATA_PLIST_PATH]) {
            DDLogWarn(@"{\"First run\":\"Tweak plist exists, run firstrun again and migrate settings\"}");
            [JFTHUtilities createFolders];
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
                
                JFTHRingtone *tone = [[JFTHRingtone alloc] init];
                [tone setGUID:[curTone objectForKey:@"GUID"]];
                [tone setMd5:[curTone objectForKey:@"Hash"]];
                [tone setBundleID:[curTone objectForKey:@"ImportedFromBundleID"]];
                [tone setName:[curTone objectForKey:@"Name"]];
                [tone setOldFileName:[curTone objectForKey:@"OldFileName"]];
                [tone setPID:[curTone objectForKey:@"PID"]];
                [tone setFileName:file];
                
                DDLogInfo(@"{\"Plist Migration\":\"Adding tone: %@\"}", tone);
                
                [_importedTonesData addRingtone:tone];
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
#pragma mark - Getters
- (NSDictionary *)importedTones {
    return [_importedTonesData importedTones];
}


#pragma mark - Add/Remove ringtones
- (void)addRingtoneToPlist:(NSString *)name 
                      file:(NSString *)fileName 
               oldFileName:(NSString *)oldFile 
              importedFrom:(NSString *)bundleID 
                      hash:(NSString *)md5 {
    // Ringtone needs to have been copied before calling this
    
    // create ringtone object
    JFTHRingtone *newtone = [[JFTHRingtone alloc] initWithName:name
                                                      fileName:fileName
                                                   oldFileName:oldFile
                                                      bundleID:bundleID];
    
    [self addRingtoneToPlist:newtone];
}

- (void)addRingtoneToPlist:(JFTHRingtone *)newtone {
    DDLogDebug(@"{\"Tweakdata:\":\"Adding ringtone to tweak data: %@\"}", newtone);
    [_importedTonesData addRingtone:newtone];
    
    if (self.shouldWriteITunesRingtonePlist && _iTunesRingtoneData.isWritable) {
        
        DDLogDebug(@"{\"iTunes plist:\":\"Adding ringtone to itunes plist: %@\"}", newtone);
        [_iTunesRingtoneData addRingtoneToITunesPlist:[newtone iTunesPlistRepresentation] fileName:[newtone fileName]];
        
    }
}

- (void)deleteRingtoneWithGUID:(NSString *)toneGUID {
    JFTHRingtone *toneToDelete = [_importedTonesData deleteRingtoneWithGuid:toneGUID];
    
    //Also try to delete from itunes plist
    if (self.shouldWriteITunesRingtonePlist && _iTunesRingtoneData.isWritable && (toneToDelete)) {
        // has permission to write and write access and tone was deleted
        [_iTunesRingtoneData deleteRingtoneFromITunesPlist:[toneToDelete fileName]];
    }
}
#pragma mark - Ringtone checks
- (BOOL)isImportedRingtoneWithName:(NSString *)name {
    if ([_importedTonesData getRingtoneWithName:name]) {
        DDLogVerbose(@"{\"Ringtone Checks\":\"Is already imported: %@\"}", name);
        return YES;
    } else {
        return NO;
    }
}
- (BOOL)isImportedRingtoneWithHash:(NSString *)hash {
    if ([_importedTonesData getRingtoneWithHash:hash]) {
        DDLogVerbose(@"{\"Ringtone Checks\":\"Is already imported based on hash\"}");
        return YES;
    } else {
        return NO;
    }
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

- (void)syncPlists:(BOOL)currentITunesWriteStatus {
    DDLogInfo(@"{\"iTunes plist sync\":\"Syncing plists with currentITunesWriteStatus = %d\"}",currentITunesWriteStatus);
    
    if ([self enableITunesRingtonePlistEditing]) {
    
        NSDictionary *importedTones = [_importedTonesData importedTones]; // dict of JFTHRingtones
        NSLog(@"2");
        for (NSString *file in importedTones) {
            NSLog(@"loop");
            JFTHRingtone *currentTone = [importedTones objectForKey:file];
            if ([_iTunesRingtoneData getITunesRingtoneWithGUID:[currentTone guid]]) {
                // this ringtone exists in itunes plist
                
                if (!currentITunesWriteStatus) {
                    
                    // and it should not exist there
                    DDLogDebug(@"{\"iTunes plist sync\":\"Deleting ringtone from itunes plist: %@\"}",currentTone);
                    [_iTunesRingtoneData deleteRingtoneFromITunesPlist:file];
                    
                }
            } else if (currentITunesWriteStatus) {
                // does not exist in itunes plist and it should exist there. Add it

                DDLogDebug(@"Adding ringtone to itunes plist: %@",currentTone);
                // Add entry to nsmutabledict (plist)
                [_iTunesRingtoneData addRingtoneToITunesPlist:[currentTone iTunesPlistRepresentation] fileName:file];
            }
        }
    }
}

@end
