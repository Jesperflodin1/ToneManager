//
//  JFTHiTunesRingtoneData.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHiTunesRingtoneData.h"
#import "JFTHCommonHeaders.h"

@interface JFTHiTunesRingtoneData () {
    NSMutableDictionary *_ringtonesPlist; //ringtones.plist
}
@end
@implementation JFTHiTunesRingtoneData

#pragma mark - init methods
- (instancetype)init {
    if (!(self = [super init])) {
        return self;
    }
    self.isWritable = NO;
    [self loadRingtonesPlist];
    
    return self;
}

#pragma mark - Plist modifiers
- (void)loadRingtonesPlist {
    DDLogDebug(@"{\"iTunes plist:\":\"Loading Ringtones.plist\"}");
    
    NSError *dataError;
    NSData *plistData = [NSData dataWithContentsOfFile:RINGTONE_PLIST_PATH options:0 error:&dataError];
    
    if (plistData) { //if plist exists, read it
        _ringtonesPlist = [NSPropertyListSerialization propertyListWithData:plistData
                                                                    options:NSPropertyListMutableContainers
                                                                     format:nil error:nil];
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        if ([localFileManager isWritableFileAtPath:RINGTONE_PLIST_PATH]) {
            self.isWritable = YES;
            DDLogDebug(@"{\"iTunes plist:\":\"iTunes plist is writable\"}");
        } else {
            self.isWritable = NO;
            DDLogError(@"{\"iTunes plist:\":\"iTunes plist is not writable\"}");
        }
    } else {
        DDLogError(@"{\"iTunes plist:\":\"Failed to read itunes plist file (creating new file): %@\"}",dataError);
        // is writable?
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        
        if ([localFileManager isWritableFileAtPath:RINGTONE_PLIST_PATH]) {
            self.isWritable = YES;
            DDLogDebug(@"{\"iTunes plist:\":\"iTunes plist is writable, creating new.\"}");
            
            //create new plist
            NSMutableDictionary *ringtones = [[NSMutableDictionary alloc] init];
            _ringtonesPlist = [[NSMutableDictionary alloc] init];
            [_ringtonesPlist setObject:ringtones forKey:@"Ringtones"];
            
        } else {
            DDLogError(@"{\"iTunes plist:\":\"iTunes plist is not writable\"}");
            self.isWritable = NO;
            return;
        }
    }
    DDLogDebug(@"{\"iTunes plist:\":\"loaded itunes plist\"}");
    
}
- (void)saveRingtonesPlist {
    // Folder may not exist, try to create it
    DDLogDebug(@"{\"iTunes plist:\":\"Saving Ringtones.plist\"}");
    
    //Write plist
    NSError *serError;
    NSData *newData = [NSPropertyListSerialization dataWithPropertyList: _ringtonesPlist
                                                                 format: NSPropertyListXMLFormat_v1_0
                                                                options: 0
                                                                  error: &serError];
    if (!newData)
        DDLogError(@"{\"iTunes plist:\":\"Error serializing ringtones plist: %@\"}",serError);
    else {
        NSError *writeError;
        if (![newData writeToFile:RINGTONE_PLIST_PATH options:NSDataWritingAtomic error:&writeError]) {

            DDLogError(@"{\"iTunes plist:\":\"Error writing ringtone plist: %@\"}",writeError);
            
        }
    }
}
- (void)removeDuplicatesInItunesPlistOf:(NSString *)name {
    int count = 0;
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
    [self saveRingtonesPlist];
}    


#pragma mark - getters & setters
- (NSDictionary *)itunesRingtones {
    return [[_ringtonesPlist objectForKey:@"Ringtones"] copy];
}

// file = key in dictionary
- (void)deleteRingtoneFromITunesPlist:(NSString *)file {
    [[_ringtonesPlist objectForKey:@"Ringtones"] removeObjectForKey:file];
    [self saveRingtonesPlist];
}

- (void)addRingtoneToITunesPlist:(NSDictionary *)tone fileName:(NSString *)file {
    // if not already in itunes plist, add it.
    if (![self getITunesRingtoneWithName:[tone objectForKey:@"Name"]]) {
        [[_ringtonesPlist objectForKey:@"Ringtones"] setObject:tone forKey:file];
        [self saveRingtonesPlist];
    }
}

- (NSDictionary *)getITunesRingtoneWithGUID:(NSString *)guid {
    NSDictionary *ringtones = [self itunesRingtones];
    DDLogVerbose(@"{\"iTunes plist:\":\"Get itunes plist\"}");
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"GUID"] isEqualToString:guid]) {
            DDLogDebug(@"{\"iTunes plist\":\" Found ringtone based on GUID (%@)\"}",[ringtones objectForKey:item]);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}
- (NSDictionary *)getITunesRingtoneWithName:(NSString *)name {
    NSDictionary *ringtones = [self itunesRingtones];
    DDLogVerbose(@"{\"iTunes plist:\":\"Get itunes plist\"}");
    for (NSString *item in ringtones) {
        if ([[[ringtones objectForKey:item] objectForKey:@"Name"] isEqualToString:name]) {
            DDLogDebug(@"{\"iTunes plist\":\" Found ringtone based on name (%@)\"}",[ringtones objectForKey:item]);
            return [ringtones objectForKey:item];
        }
    }
    return nil;
}

@end
