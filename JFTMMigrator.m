//
//  JFTMMigrator.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-31.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTMMigrator.h"

@implementation JFTMMigrator

+(void)_migratePlistData { // TODO: Add check so we dont get duplicates
   /* DDLogInfo(@"{\"Plist Migration\":\"Migrating plist data to preferences\"}");
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
                
                JFTMRingtone *tone = [[JFTMRingtone alloc] initWithName:[curTone objectForKey:@"Name"]
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
    */
}

+ (void)removeDuplicatesInItunesPlistOf:(NSString *)name {
   /* int count = 0;
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    
    NSDictionary *ringtones = [self itunesRingtones];
    DDLogInfo(@"{\"iTunes plist:\":\"Looking for duplicates\"}");
    
    for (NSString *file in ringtones) {
        if ([[[ringtones objectForKey:file] objectForKey:@"Name"] isEqualToString:file]) {
            count++;
            [itemsToDelete addObject:file];
        }
    }
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (count > 1) {
        for (NSString *file in itemsToDelete) {
            DDLogWarn(@"{\"iTunes plist:\":\"Found duplicate in itunes plist, removing: (%@)\"}",file);
            [self deleteRingtoneFromITunesPlist:file];
            
            NSError *error;
            if (![localFileManager removeItemAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:file] error:&error])
                DDLogError(@"{\"iTunes plist:\":\"Failed to delete file: %@\"}", error);
        }
    }
    [self saveRingtonesPlist];*/
}

@end
