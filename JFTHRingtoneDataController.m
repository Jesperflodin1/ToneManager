#import "JFTHRingtoneDataController.h"
#import "JFTHRingtoneImporter.h"

NSString * const RINGTONE_PLIST_PATH = @"/var/mobile/Media/iTunes_Control/iTunes/Ringtones.plist";
NSString * const TONEHELPERDATA_PLIST_PATH = @"/var/mobile/Library/Application Support/ToneHelper/ToneHelperData.plist";

@interface JFTHRingtoneDataController () {
    NSMutableDictionary *_importedRingtonesPlist; 
    NSMutableDictionary *_ringtonesPlist; //ringtones.plist
}

@end

@implementation JFTHRingtoneDataController

- (instancetype)init {
    if (self = [super init]) {
        [self loadTweakPlist];
        self.shouldWriteITunesRingtonePlist = NO;
    }
    return self;
}

- (BOOL)enableITunesRingtonePlistEditing {
    self.shouldWriteITunesRingtonePlist = YES;
    return [self loadRingtonesPlist];
}

- (NSDictionary *)getItunesRingtones {
    return [[_ringtonesPlist objectForKey:@"Ringtones"] copy];
}
- (NSDictionary *)getImportedRingtones {
    return [[_importedRingtonesPlist objectForKey:@"Ringtones"] copy];
}

- (void)loadTweakPlist {
    NSData *plistData = [NSData dataWithContentsOfFile:TONEHELPERDATA_PLIST_PATH];
    if (plistData) { //if plist exists, read it
        _importedRingtonesPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                            options:NSPropertyListMutableContainers
                                                            format:nil error:nil];
    } else { //create new plist
        _importedRingtonesPlist = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *importedRingtones = [[NSMutableDictionary alloc] init];
        [_importedRingtonesPlist setObject:importedRingtones forKey:@"Ringtones"];
    }

}
- (BOOL)loadRingtonesPlist {
    NSLog(@"Ringtone Importer: Loading Ringtones.plist");
    
    NSError *dataError;
    NSData *plistData = [NSData dataWithContentsOfFile:RINGTONE_PLIST_PATH options:0 error:&dataError];
    if (!plistData) {
        DLog(@"Failed to read itunes plist file: %@",dataError);
        return NO;
    }
    
    if (plistData) { //if plist exists, read it
        _ringtonesPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                            options:NSPropertyListMutableContainers
                                                            format:nil error:nil];
    } else { //create new plist
        NSMutableDictionary *ringtones = [[NSMutableDictionary alloc] init];
        _ringtonesPlist = [[NSMutableDictionary alloc] init];
        [_ringtonesPlist setObject:ringtones forKey:@"Ringtones"];
    }
    DLog(@"Read itunes plist: %@",_ringtonesPlist);
    return YES;
}
- (void)saveTweakPlist {
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _importedRingtonesPlist
                                                                 format: NSPropertyListBinaryFormat_v1_0
                                                                options: 0
                                                                  error: nil];
    [newData writeToFile:TONEHELPERDATA_PLIST_PATH atomically:YES];
}
- (void)saveRingtonesPlist {
    //Write plist
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _ringtonesPlist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: nil];
    [newData writeToFile:RINGTONE_PLIST_PATH atomically:YES];
}
- (void)save {
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



- (void)deleteRingtoneWithFilename:(NSString *)filename {

}
/*- (NSDictionary *)getRingtoneWithFilename:(NSString *)filename {

}*/
- (NSDictionary *)getRingtoneWithName:(NSString *)name {
    NSDictionary *ringtones = [self getImportedRingtones];
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            NSLog(@"Ringtone Importer: Found ringtone that already is imported based on filename, skipping. (%@)",item);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getRingtoneWithHash:(NSString *)md5 {
    NSDictionary *ringtones = [self getImportedRingtones];
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Hash"] isEqualToString:md5]) {
            NSLog(@"Ringtone Importer: Found ringtone that already is imported based on hash, skipping. (%@)",item);
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
            NSLog(@"Ringtone Importer: Found ringtone that already is imported based on GUID, skipping. (%@)",item);
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
        DLog(@"Syncing plists with currentITunesWriteStatus = %d",currentITunesWriteStatus);
        JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];

        // Need write access to itunes plist
        if (![toneData enableITunesRingtonePlistEditing])
            return; // injected into process which cant write to the file

        NSDictionary *importedTones = [toneData getImportedRingtones];

        for (NSString *file in importedTones) {
            if ([toneData getITunesRingtoneWithGUID:[[importedTones objectForKey:file] objectForKey:@"GUID"]]) {
                // this ringtone exists in itunes plist
                if (!currentITunesWriteStatus) {
                    // and it should not exist there
                    DLog(@"Deleting ringtone from itunes plist: %@",[importedTones objectForKey:file]);
                    [toneData deleteRingtoneFromITunesPlist:file];
                }
            } else if (currentITunesWriteStatus) {
                // does not exist in itunes plist
                // and it should exist there. Add it
                DLog(@"Adding ringtone to itunes plist: %@",[importedTones objectForKey:file]);
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

+ (NSArray *)getImportedRingtones {
    JFTHRingtoneDataController *toneData = [[JFTHRingtoneDataController alloc] init];

    NSMutableArray *tonesArray = [[NSMutableArray alloc] init];
    NSDictionary *importedTones = [toneData getImportedRingtones];

    for (NSString *file in importedTones) {
        [tonesArray addObject:file];
    }

    return tonesArray; 
}

@end