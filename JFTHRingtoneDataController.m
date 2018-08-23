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
        ALog(@"First run: %d",kFirstRun); // YES = first run done.

        [self loadTweakPlist];
        [self loadRingtonesPlist];
        self.shouldWriteITunesRingtonePlist = NO;

        if (!kFirstRun)
            [self firstRun];
        ALog(@"Initialized");
    }
    return self;
}

- (BOOL)enableITunesRingtonePlistEditing {
    self.shouldWriteITunesRingtonePlist = YES;
    DLog(@"shouldWriteITunesRingtonePlist = %d",self.shouldWriteITunesRingtonePlist);
    return [self loadRingtonesPlist];
}

- (NSDictionary *)getItunesRingtones {
    DLog(@"Itunes ringtones: %@", [_ringtonesPlist objectForKey:@"Ringtones"]);
    return [_ringtonesPlist objectForKey:@"Ringtones"];
}
- (NSDictionary *)getImportedRingtones {
    DLog(@"Ringtones: %@",[_importedRingtonesPlist objectForKey:@"Ringtones"]);
    return [_importedRingtonesPlist objectForKey:@"Ringtones"];
}

- (void)firstRun {
    ALog(@"First run! Preparing folders");
    NSError *dirError;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/iTunes/"
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:&dirError]) {
        ALog(@"Error creating ringtones folder: %@",dirError);
    } else
        ALog(@"Success itunes folder");

    NSError *ITdirError;
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/Ringtones"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&ITdirError]) {
        ALog(@"Error creating Ringtone folder:%@",ITdirError);
    } else
        ALog(@"Success ringtones folder");


    //fix duplicates in itunes plist

    NSDictionary *ringtones = [[self getItunesRingtones] copy];
    DLog(@"Read itunes plist: %@",ringtones);
    for (NSString *item in ringtones) {
        [self removeDuplicatesInItunesPlistOf:[[ringtones objectForKey:item] objectForKey:@"Name"]];
    }

    // make sure the files exist
    [self saveRingtonesPlist];
    [self saveTweakPlist];
    ALog(@"Firstrun done");
    //firstrun done, dont run again
    [preferences setBool:YES forKey:@"kFirstRun"];
}

- (void)removeDuplicatesInItunesPlistOf:(NSString *)name {
    int count = 0;
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];

    NSDictionary *ringtones = [[self getItunesRingtones] copy];
    DLog(@"Read itunes plist: %@",ringtones);
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            count++;
            [itemsToDelete addObject:item];
        }
    }
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (count > 1) {
        for (NSString *item in itemsToDelete) {
            DLog(@"Found duplicate in itunes plist: (%@)",item);
            [[_ringtonesPlist objectForKey:@"Ringtones"] removeObjectForKey:item];
            DLog(@"Removing duplicate file");
            NSError *error;
            if (![localFileManager removeItemAtPath:[@"/var/mobile/Media/iTunes_Control/Ringtones" stringByAppendingPathComponent:item] error:&error])
                ALog(@"Failed to remove item: %@", error);
        }
    }
}    

- (void)loadTweakPlist {
    ALog(@"Loading tweak plist");
    NSError *readError;
    NSData *plistData = [NSData dataWithContentsOfFile:TONEHELPERDATA_PLIST_PATH options:0 error:&readError];
    if (plistData) { //if plist exists, read it
        _importedRingtonesPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                            options:NSPropertyListMutableContainers
                                                            format:nil error:nil];
        DLog(@"Read tweak plist: %@",_importedRingtonesPlist);
    } else { //create new plist
        ALog(@"Error loading tweak plist: %@",readError);
        _importedRingtonesPlist = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *importedRingtones = [[NSMutableDictionary alloc] init];
        [_importedRingtonesPlist setObject:importedRingtones forKey:@"Ringtones"];
        ALog(@"Creating new tweak plist");
    }

}
- (BOOL)loadRingtonesPlist {
    ALog(@"Ringtone Importer: Loading Ringtones.plist");
    
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

        DLog(@"Failed to read itunes plist file (creating new file): %@",dataError);
        // First run? create plist
        [self saveRingtonesPlist];
        return NO;
    }
    DLog(@"Read itunes plist: %@",_ringtonesPlist);
    return YES;
}
- (void)saveTweakPlist {
    ALog(@"Saving tweak plist");
    NSError *serError;
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _importedRingtonesPlist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: &serError];
    if (!newData)    
        ALog(@"Error serializing tweak plist: %@",serError);
    NSError *writeError;
    if (![newData writeToFile:TONEHELPERDATA_PLIST_PATH options:NSDataWritingAtomic error:&writeError])
        ALog(@"Error writing tweak plist: %@",writeError);
}
- (void)saveRingtonesPlist {
    // Folder may not exist, try to create it
    ALog(@"Saving Ringtones.plist");
    
    //Write plist
    NSError *serError;
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _ringtonesPlist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: &serError];
    if (!newData)
        ALog(@"Error serializing ringtones plist: %@",serError);

    NSError *writeError;
    if (![newData writeToFile:RINGTONE_PLIST_PATH options:NSDataWritingAtomic error:&writeError])
        ALog(@"Error writing ringtone plist: %@",writeError);
}
- (void)save {
    ALog(@"Saving plists");
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
        ALog(@"Adding ringtone i itunes plist: %@", name);
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

            ALog(@"Deleting ringtone: %@",item);

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
            ALog(@"Ringtone Importer: Found ringtone that already is imported based on filename, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getRingtoneWithHash:(NSString *)md5 {
    NSDictionary *ringtones = [self getImportedRingtones];
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Hash"] isEqualToString:md5]) {
            ALog(@"Ringtone Importer: Found ringtone that already is imported based on hash, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getITunesRingtoneWithGUID:(NSString *)guid {
    NSDictionary *ringtones = [self getItunesRingtones];
    DLog(@"Read itunes plist: %@",ringtones);
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"GUID"] isEqualToString:guid]) {
            ALog(@"Ringtone Importer: Found ringtone that already is imported based on GUID, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getITunesRingtoneWithName:(NSString *)name {
    NSDictionary *ringtones = [self getItunesRingtones];
    DLog(@"Read itunes plist: %@",ringtones);
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            ALog(@"Ringtone Importer: Found ringtone in itunes plist that already is imported based on Name, skipping. (%@)",item);
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
        ALog(@"Syncing plists with currentITunesWriteStatus = %d",currentITunesWriteStatus);
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];

        // Need write access to itunes plist
        //if (![toneData enableITunesRingtonePlistEditing])
            //return; // injected into process which cant write to the file

        NSDictionary *importedTones = [toneData getImportedRingtones];

        for (NSString *file in importedTones) {
            if ([toneData getITunesRingtoneWithGUID:[[importedTones objectForKey:file] objectForKey:@"GUID"]]) {
                // this ringtone exists in itunes plist
                if (!currentITunesWriteStatus) {
                    // and it should not exist there
                    ALog(@"Deleting ringtone from itunes plist: %@",[importedTones objectForKey:file]);
                    [toneData deleteRingtoneFromITunesPlist:file];
                }
            } else if (currentITunesWriteStatus) {
                // does not exist in itunes plist
                // and it should exist there. Add it
                ALog(@"Adding ringtone to itunes plist: %@",[importedTones objectForKey:file]);
                NSMutableDictionary *currentTone = [[NSMutableDictionary alloc] init];
                [currentTone setObject:[[importedTones objectForKey:file] objectForKey:@"GUID"] forKey:@"GUID"];
                [currentTone setObject:[[importedTones objectForKey:file] objectForKey:@"Name"] forKey:@"Name"];
                [currentTone setObject:[[importedTones objectForKey:file] objectForKey:@"PID"] forKey:@"PID"];
                [currentTone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
                // Add entry to nsmutabledict (plist)
                [toneData addRingtoneToITunesPlist:currentTone fileName:file];
            }
        }
        [toneData saveRingtonesPlist];
        toneData = nil;
    }
}

@end