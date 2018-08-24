#import "JFTHRingtoneDataController.h"


NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/ToneHelper/ToneHelperData.plist";
//NSString * const RINGTONE_DIRECTORY = @"/var/mobile/Media/iTunes_Control/Ringtones";

@interface JFTHRingtoneDataController () {
    NSMutableDictionary *_importedRingtonesPlist; 
    NSMutableDictionary *_ringtonesPlist; //ringtones.plist
}

@end

BOOL kFirstRun;

extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;

@implementation JFTHRingtoneDataController

- (instancetype)init {
    if (self = [super init]) {
        
        preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
        [preferences registerBool:&kFirstRun default:NO forKey:@"kFirstRun"];
        DDLogInfo(@"First run: %d",kFirstRun); // YES = first run done.

        [self loadTweakPlist];
        [self loadRingtonesPlist];
        self.shouldWriteITunesRingtonePlist = NO;

        if (!kFirstRun)
            [self firstRun];
        
        // check folder existence
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if (![localFileManager fileExistsAtPath:@"/var/mobile/Library/ToneHelper"]) {
            // somethings wrong, run fisrtrun again
            DDLogError(@"Tweak folder non-existent. Running firstrun again");
            [self firstRun];
        } else
            DDLogInfo(@"Tweak folder exists.");

            
        DDLogDebug(@"Initialized");
    }
    return self;
}


- (BOOL)enableITunesRingtonePlistEditing {
    self.shouldWriteITunesRingtonePlist = YES;
    DDLogDebug(@"shouldWriteITunesRingtonePlist = %d",self.shouldWriteITunesRingtonePlist);
    return [self loadRingtonesPlist];
}

- (NSDictionary *)getItunesRingtones {
    DDLogDebug(@"Get Itunes ringtones");
    return [_ringtonesPlist objectForKey:@"Ringtones"];
}
- (NSDictionary *)getImportedRingtones {
    DDLogDebug(@"Get imported Ringtones");
    return [_importedRingtonesPlist objectForKey:@"Ringtones"];
}

- (void)firstRun {
    DDLogWarn(@"First run! Preparing folders");
    NSError *dirError;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/iTunes/"
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&dirError]) {
        DDLogError(@"Error creating ringtones folder: %@",dirError);
    } else
        DDLogWarn(@"Success itunes folder");

    NSError *ITdirError;
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/Ringtones"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&ITdirError]) {
        DDLogError(@"Error creating Ringtone folder:%@",ITdirError);
    } else
        DDLogWarn(@"Success ringtones folder");
    
    NSError *tweakdirError;
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Library/ToneHelper/"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&tweakdirError]) {
        DDLogError(@"Error creating ringtones folder: %@",tweakdirError);
    } else
        DDLogWarn(@"Success creating tweak folder");


    //fix duplicates in itunes plist

    NSDictionary *ringtones = [[self getItunesRingtones] copy];
    DDLogInfo(@"Read itunes plist");
    for (NSString *item in ringtones) {
        [self removeDuplicatesInItunesPlistOf:[[ringtones objectForKey:item] objectForKey:@"Name"]];
    }

    // make sure the files exist
    [self saveRingtonesPlist];
    [self saveTweakPlist];
    DDLogWarn(@"Firstrun done");
    //firstrun done, dont run again
    [preferences setBool:YES forKey:@"kFirstRun"];
}

- (void)removeDuplicatesInItunesPlistOf:(NSString *)name {
    int count = 0;
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];

    NSDictionary *ringtones = [[self getItunesRingtones] copy];
    DDLogInfo(@"Read itunes plist");
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            count++;
            [itemsToDelete addObject:item];
        }
    }
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (count > 1) {
        for (NSString *item in itemsToDelete) {
            DDLogWarn(@"Found duplicate in itunes plist: (%@)",item);
            [[_ringtonesPlist objectForKey:@"Ringtones"] removeObjectForKey:item];
            DDLogWarn(@"Removing duplicate file");
            NSError *error;
            if (![localFileManager removeItemAtPath:[@"/var/mobile/Media/iTunes_Control/Ringtones" stringByAppendingPathComponent:item] error:&error])
                DDLogError(@"Failed to remove item: %@", error);
        }
    }
}    

- (void)loadTweakPlist {
    DDLogDebug(@"Loading tweak plist");
    NSError *readError;
    NSData *plistData = [NSData dataWithContentsOfFile:TONEHELPERDATA_PLIST_PATH options:0 error:&readError];
    if (plistData) { //if plist exists, read it
        _importedRingtonesPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                            options:NSPropertyListMutableContainers
                                                            format:nil error:nil];
        DDLogDebug(@"loaded tweak plist");
    } else { //create new plist
        DDLogWarn(@"Error loading tweak plist: %@",readError);
        _importedRingtonesPlist = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *importedRingtones = [[NSMutableDictionary alloc] init];
        [_importedRingtonesPlist setObject:importedRingtones forKey:@"Ringtones"];
        DDLogInfo(@"Creating new tweak plist");
        [self saveTweakPlist];
    }

}
- (BOOL)loadRingtonesPlist {
    DDLogDebug(@"Ringtone Importer: Loading Ringtones.plist");
    
    NSError *dataError;
    NSData *plistData = [NSData dataWithContentsOfFile:RINGTONE_PLIST_PATH options:0 error:&dataError];
    
    if (plistData) { //if plist exists, read it
        _ringtonesPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                            options:NSPropertyListMutableContainers
                                                            format:nil error:nil];
    } else { //create new plist
        NSMutableDictionary *ringtones = [[NSMutableDictionary alloc] init];
        _ringtonesPlist = [[NSMutableDictionary alloc] init];
        [_ringtonesPlist setObject:ringtones forKey:@"Ringtones"];

        DDLogError(@"Failed to read itunes plist file (creating new file): %@",dataError);
        // First run? create plist
        [self saveRingtonesPlist];
        return NO;
    }
    DDLogDebug(@"loaded itunes plist");
    return YES;
}
- (void)saveTweakPlist {
    DDLogDebug(@"Saving tweak plist");
    NSError *serError;
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _importedRingtonesPlist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: &serError];
    if (!newData)    
        DDLogError(@"Error serializing tweak plist: %@",serError);
    NSError *writeError;
    if (![newData writeToFile:TONEHELPERDATA_PLIST_PATH options:NSDataWritingAtomic error:&writeError])
        DDLogError(@"Error writing tweak plist: %@",writeError);
}
- (void)saveRingtonesPlist {
    // Folder may not exist, try to create it
    DDLogDebug(@"Saving Ringtones.plist");
    
    //Write plist
    NSError *serError;
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _ringtonesPlist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: &serError];
    if (!newData)
        DDLogError(@"Error serializing ringtones plist: %@",serError);

    NSError *writeError;
    if (![newData writeToFile:RINGTONE_PLIST_PATH options:NSDataWritingAtomic error:&writeError])
        DDLogError(@"Error writing ringtone plist: %@",writeError);
}
- (void)save {
    DDLogDebug(@"Saving plists");
    [self saveTweakPlist];
    if (self.shouldWriteITunesRingtonePlist)
        [self saveRingtonesPlist];
}



- (void)addRingtoneToPlist:(NSString *)name 
                      file:(NSString *)fileName 
               oldFileName:(NSString *)oldFile 
              importedFrom:(NSString *)bundleID 
                      hash:(NSString *)md5 {
    // name (show in ringtonepicker)
    //filename (filename of m4r file)
    NSString *toneGUID = [self randomizedRingtoneParameter:JFTHRingtoneGUID];
    NSNumber *tonePID = [NSNumber numberWithLongLong:[[self randomizedRingtoneParameter:JFTHRingtonePID] longLongValue]];

    if (self.shouldWriteITunesRingtonePlist) {
        DDLogDebug(@"Adding ringtone to itunes plist: %@", name);
        // Does this ringtone already exist in itunes ringtone plist?



        NSMutableDictionary *currentTone = [[NSMutableDictionary alloc] init];
        [currentTone setObject:toneGUID forKey:@"GUID"];
        [currentTone setObject:name forKey:@"Name"];
        [currentTone setObject:tonePID forKey:@"PID"];
        [currentTone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
        // Add entry to nsmutabledict (plist)
        [[_ringtonesPlist objectForKey:@"Ringtones"] setObject:currentTone forKey:fileName];
    }

    // Also add to our own data plist
    NSMutableDictionary *importedTone = [[NSMutableDictionary alloc] init];
    [importedTone setObject:name forKey:@"Name"];
    [importedTone setObject:toneGUID forKey:@"GUID"];
    [importedTone setObject:tonePID forKey:@"PID"];
    [importedTone setObject:bundleID forKey:@"ImportedFromBundleID"];
    [importedTone setObject:oldFile forKey:@"OldFileName"];
    [importedTone setObject:md5 forKey:@"Hash"];
    [[_importedRingtonesPlist objectForKey:@"Ringtones"] setObject:importedTone forKey:fileName];
    // Does not save plist automatically. call saveRingtonesPlist when done.
}



- (void)deleteRingtoneWithGUID:(NSString *)guid {
    NSDictionary *ringtones = [self getImportedRingtones];
    // find the ringtone
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"GUID"] isEqualToString:guid]) {

            DDLogDebug(@"Deleting ringtone: %@",item);

            NSFileManager *localFileManager = [[NSFileManager alloc] init];
            [localFileManager removeItemAtPath:[@"/var/mobile/Media/iTunes_Control/Ringtones" stringByAppendingPathComponent:item] error:nil];
            [[_importedRingtonesPlist objectForKey:@"Ringtones"] removeObjectForKey:item];
            [self saveTweakPlist];

            //Also try to delete from itunes plist
            [self loadRingtonesPlist];
            [self deleteRingtoneFromITunesPlist:item];
            [self saveRingtonesPlist];
        }
    }
}
/*- (NSDictionary *)getRingtoneWithFilename:(NSString *)filename {

}*/
- (NSDictionary *)getRingtoneWithName:(NSString *)name {
    NSDictionary *ringtones = [self getImportedRingtones];
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            DDLogDebug(@"Ringtone Importer: Found ringtone that already is imported based on filename, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getRingtoneWithHash:(NSString *)md5 {
    NSDictionary *ringtones = [self getImportedRingtones];
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Hash"] isEqualToString:md5]) {
            DDLogDebug(@"Ringtone Importer: Found ringtone that already is imported based on hash, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getITunesRingtoneWithGUID:(NSString *)guid {
    NSDictionary *ringtones = [self getItunesRingtones];
    DDLogVerbose(@"Get itunes plist");
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"GUID"] isEqualToString:guid]) {
            DDLogDebug(@"Ringtone Importer: Found ringtone that already is imported based on GUID, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getITunesRingtoneWithName:(NSString *)name {
    NSDictionary *ringtones = [self getItunesRingtones];
    DDLogVerbose(@"Get itunes plist");
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            DDLogDebug(@"Ringtone Importer: Found ringtone in itunes plist that already is imported based on Name, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}

// Generates filename, PID and GUID needed to import ringtone
- (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type {
    int length;
    NSString *alphabet;
    NSString *result = @"";
    switch (Type) 
    {
        case JFTHRingtonePID:
            length = 18;
            result = @"-";
            alphabet = @"0123456789";
            break;
        case JFTHRingtoneGUID:
            alphabet = @"ABCDEFG0123456789";
            length = 16;
            break;
        case JFTHRingtoneFileName:
            alphabet = @"ABCDEFGHIJKLMNOPQRSTUVWXZ";
            length = 4;
            break;
        default:
            return nil;
            break;
    }
    NSMutableString *s = [NSMutableString stringWithCapacity:length];
    for (NSUInteger i = 0U; i < length; i++) {
        u_int32_t r = arc4random() % [alphabet length];
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    return [result stringByAppendingString:s];
}
// file = key in dictionary
- (void)deleteRingtoneFromITunesPlist:(NSString *)file {
    [[_ringtonesPlist objectForKey:@"Ringtones"] removeObjectForKey:file];
}
- (void)addRingtoneToITunesPlist:(NSDictionary *)tone fileName:(NSString *)file {
    [[_ringtonesPlist objectForKey:@"Ringtones"] setObject:tone forKey:file];
}

+ (void)syncPlists:(BOOL)currentITunesWriteStatus {
    @autoreleasepool { 
        DDLogDebug(@"Syncing plists with currentITunesWriteStatus = %d",currentITunesWriteStatus);
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];

        // Need write access to itunes plist
        //if (![toneData enableITunesRingtonePlistEditing])
            //return; // injected into process which cant write to the file

        NSDictionary *importedTones = [toneData getImportedRingtones];

        for (NSString *file in importedTones) {
            @autoreleasepool {
                if ([toneData getITunesRingtoneWithGUID:[[importedTones objectForKey:file] objectForKey:@"GUID"]]) {
                    // this ringtone exists in itunes plist
                    if (!currentITunesWriteStatus) {
                        // and it should not exist there
                        DDLogInfo(@"Deleting ringtone from itunes plist: %@",[importedTones objectForKey:file]);
                        [toneData deleteRingtoneFromITunesPlist:file];
                    }
                } else if (currentITunesWriteStatus) {
                    // does not exist in itunes plist
                    // and it should exist there. Add it
                    DDLogInfo(@"Adding ringtone to itunes plist: %@",[importedTones objectForKey:file]);
                    NSMutableDictionary *currentTone = [[NSMutableDictionary alloc] init];
                    [currentTone setObject:[[importedTones objectForKey:file] objectForKey:@"GUID"] forKey:@"GUID"];
                    [currentTone setObject:[[importedTones objectForKey:file] objectForKey:@"Name"] forKey:@"Name"];
                    [currentTone setObject:[[importedTones objectForKey:file] objectForKey:@"PID"] forKey:@"PID"];
                    [currentTone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
                    // Add entry to nsmutabledict (plist)
                    [toneData addRingtoneToITunesPlist:currentTone fileName:file];
                }
            }
        }
        [toneData saveRingtonesPlist];
        toneData = nil;
    }
}

@end
