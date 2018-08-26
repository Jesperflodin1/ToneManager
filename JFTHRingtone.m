//
//  JFTHRingtone.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHRingtone.h"
#import "JFTHUtilities.h"
#import "JFTHHeaders.h"
#import "FileHash.h"
#import "JFTHConstants.h"

@interface JFTHRingtone () {
    NSMutableDictionary *_ringtone;
}
@end

@implementation JFTHRingtone
#pragma mark - Init methods
- (instancetype)init {
    if (!(self = [super init]))
        return self;
    
    _ringtone = [NSMutableDictionary dictionary];
    
    return self;
}

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID
{
    if (!(self = [super init]))
        return self;
    
    _ringtone = [NSMutableDictionary dictionary];
    [_ringtone setObject:name forKey:@"Name"];
    [_ringtone setObject:fileName forKey:@"FileName"];
    
    NSString *md5 = [FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:fileName]];
    [_ringtone setObject:md5 forKey:@"Hash"];
    [_ringtone setObject:oldFileName forKey:@"OldFileName"];
    [_ringtone setObject:bundleID forKey:@"ImportedFromBundleID"];
    [_ringtone setObject:[JFTHRingtone randomizedRingtoneParameter:JFTHRingtonePID] forKey:@"PID"];
    [_ringtone setObject:[JFTHRingtone randomizedRingtoneParameter:JFTHRingtoneGUID] forKey:@"GUID"];
    
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with data: %@\"}", _ringtone);
    
    return self;
}

- (void)initWithDictionary:(NSMutableDictionary *)dict {
    if (dict) {
        if (![dict objectForKey:@"Total Time"]) {
            // TODO: Get total time
        }
        _ringtone = dict;
    }
}
#pragma mark - Setters Getters
- (void)setName:(NSString *)name {
    [_ringtone setObject:name forKey:@"Name"];
}
- (NSString *)name {
    return [_ringtone objectForKey:@"Name"];
}

- (void)setFileName:(NSString *)fileName {
    [_ringtone setObject:fileName forKey:@"FileName"];
    
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with file: %@\"}", fileName);
    NSString *md5 = [FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:fileName]];
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with hash: %@\"}", md5);
    [_ringtone setObject:md5 forKey:@"Hash"];
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with hash: %@\"}", [self md5]);
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with hash: %@\"}", [_ringtone objectForKey:@"Hash"]);
}
- (NSString *)fileName {
    return [_ringtone objectForKey:@"FileName"];
}

- (void)setOldFileName:(NSString *)oldFileName {
    [_ringtone setObject:oldFileName forKey:@"OldFileName"];
}
- (NSString *)oldFileName {
    return [_ringtone objectForKey:@"OldFileName"];
}

- (void)setBundleID:(NSString *)bundleID {
    [_ringtone setObject:bundleID forKey:@"ImportedFromBundleID"];
}
- (NSString *)bundleID {
    return [_ringtone objectForKey:@"ImportedFromBundleID"];
}

- (void)setMd5:(NSString *)md5 {
    [_ringtone setObject:md5 forKey:@"Hash"];
}
- (NSString *)md5 {
    return [_ringtone objectForKey:@"Hash"];
}

- (void)setPID:(NSNumber *)pid {
    [_ringtone setObject:pid forKey:@"PID"];
}
- (NSNumber *)pid {
    return [_ringtone objectForKey:@"PID"];
}

- (void)setGUID:(NSString *)guid {
    [_ringtone setObject:guid forKey:@"GUID"];
}
- (NSString *)guid {
    return [_ringtone objectForKey:@"GUID"];
}
- (void)setTotalTime:(NSString *)totalTime {
    [_ringtone setObject:totalTime forKey:@"Total Time"];
}
- (NSString *)totalTime {
    return [_ringtone objectForKey:@"Total Time"];
}

#pragma mark - Converts to format ToneLibrary understands
- (NSDictionary *)iTunesPlistRepresentation {
    NSMutableDictionary *tone;
    [tone setObject:[self guid] forKey:@"GUID"];
    [tone setObject:[self name] forKey:@"Name"];
    [tone setObject:[self pid] forKey:@"PID"];
    [tone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
    
    return tone;
}

#pragma mark - Dictionary representation for sending to storage
- (NSDictionary *)dictionaryRepresentation {
    DDLogVerbose(@"{\"Ringtone init\":\"sending dict repr: %@\"}", _ringtone);
    return _ringtone;
}

#pragma mark - Methods for calculated values
+ (int)totalTimeForRingtoneFilePath:(NSString *)filePath {
    // TODO: CODE
}

// Generates filename, PID and GUID needed to import ringtone
+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type {
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


@end
