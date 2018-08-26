//
//  JFTHRingtoneData.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHRingtoneData.h"

// TODO: Change to property?
NSDictionary *_ringtonesImported; // TODO: Shouldnt this be an array of JFTHRingtone objects?

extern NSString *const HBPreferencesDidChangeNotification;
HBPreferences *preferences;

@implementation JFTHRingtoneData

- (instancetype)init {
    if (!(self = [super init])) {
        return self;
    }
    preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
    [preferences registerObject:&_ringtonesImported default:[NSDictionary dictionary] forKey:@"Ringtones"];
    
    DDLogDebug(@"{\"Ringtone info\":\"Got tones from preferences: %@\"}", _ringtonesImported);
    
    
    return self;
}


#pragma mark - Add & Delete
- (void)addRingtone:(JFTHRingtone *)ringtone  {
    NSMutableDictionary *tones = [self importedTones];
    DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones before adding: %@\"}", tones);
    DDLogVerbose(@"{\"Ringtone info\":\"Tone to be imported: %@\"}", ringtone);
    DDLogVerbose(@"{\"Ringtone info\":\"Tone to be imported dictrepr: %@\"}", [ringtone dictionaryRepresentation]);
    DDLogVerbose(@"{\"Ringtone info\":\"Tone to be imported filename: %@\"}", [ringtone fileName]);
    [tones setObject:[ringtone dictionaryRepresentation] forKey:[ringtone fileName]]; // TODO Store JFTHRingtone in an array
    
    [preferences setObject:tones forKey:@"Ringtones"];
    DDLogDebug(@"{\"Ringtone info\":\"Adding ringtone: %@\"}", ringtone);
    DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones: %@\"}", _ringtonesImported);
}

- (JFTHRingtone *)deleteRingtoneWithGuid:(NSString *)toneGUID {
    NSMutableDictionary *tones = [self importedTones];
    
    for (NSString *file in tones) {
        if ([[[tones objectForKey:file] guid] isEqualToString:toneGUID]) {
            
            NSError *error;
            NSFileManager *localFileManager = [[NSFileManager alloc] init];
            if ([localFileManager removeItemAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:file] error:&error]) {
                
                NSMutableDictionary *newTones = [self importedTones];
                [newTones removeObjectForKey:file];
                [preferences setObject:newTones forKey:@"Ringtones"];
                
                DDLogDebug(@"{\"Ringtone info\":\"Deleting ringtone: %@\"}", [tones objectForKey:file]);
                DDLogVerbose(@"{\"Ringtone info\":\"Currently imported tones: %@\"}", _ringtonesImported);
                return [tones objectForKey:file];
            } else {
                DDLogError(@"{\"Ringtone info\":\"Failed to delete ringtone: %@\"}", error);
                return nil;
            }
        }
    }
    return nil;
}

- (void)deleteRingtoneWithFileName:(NSString *)FileName {
    NSMutableDictionary *tones = [self importedTones];
    [tones removeObjectForKey:FileName];
    
    [preferences setObject:tones forKey:@"Ringtones"];
    
    DDLogDebug(@"{\"Ringtone info\":\"Deleting ringtone: %@\"}", [tones objectForKey:FileName]);
}


#pragma mark - Getters
//TODO: Return objectEnumerator of NSArray (https://developer.apple.com/documentation/foundation/nsarray/1416048-objectenumerator?language=objc)
// Seems dumb to use this instead of the instance variable in this class...
- (NSMutableDictionary *)importedTones {
    return [_ringtonesImported mutableCopy];
}

- (JFTHRingtone *)getRingtoneWithName:(NSString *)name {
    NSDictionary *ringtones = [self importedTones];
    
    for (NSString *file in ringtones) {
        if ([[[ringtones objectForKey:file] name] isEqualToString:name]) {
            DDLogDebug(@"{\"Ringtone info\":\"Found ringtone base on Name: (%@)\"}",[ringtones objectForKey:file]);
            return [ringtones objectForKey:file];
        }
    }
    return nil;
}
- (JFTHRingtone *)getRingtoneWithHash:(NSString *)md5 {
    NSDictionary *ringtones = [self importedTones];
    for (NSString *file in ringtones) {
        if ([[[ringtones objectForKey:file] md5] isEqualToString:md5]) {
            DDLogDebug(@"{\"Ringtone info\":\"Found ringtone base on Hash: (%@)\"}",[ringtones objectForKey:file]);
            return [ringtones objectForKey:file];
        }
    }
    return nil;
}
- (JFTHRingtone *)getRingtoneWithGUID:(NSString *)toneGUID {
    NSDictionary *ringtones = [self importedTones];
    for (NSString *file in ringtones) {
        if ([[[ringtones objectForKey:file] guid] isEqualToString:toneGUID]) {
            DDLogDebug(@"{\"Ringtone info\":\"Found ringtone base on Hash: (%@)\"}",[ringtones objectForKey:file]);
            return [ringtones objectForKey:file];
        }
    }
    return nil;
}


#pragma mark - iTunes plist stuff
- (NSDictionary *)iTunesPlistRepresentation {
    NSMutableDictionary *allTones = [[NSMutableDictionary alloc] init];
    for (JFTHRingtone *tone in [self importedTones]) {
            
        [allTones setObject:[tone iTunesPlistRepresentation] forKey:[tone fileName]];
        
        DDLogVerbose(@"{\"Ringtone info\":\"iTunes plist representation: %@\"}", [tone iTunesPlistRepresentation]);
    }
    DDLogVerbose(@"{\"Ringtone info\":\"iTunes plist representation for all tones: %@\"}", allTones);
    return allTones;
}

@end
