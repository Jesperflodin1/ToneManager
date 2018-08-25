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
    [_ringtone setObject:[JFTHUtilities randomizedRingtoneParameter:JFTHRingtonePID] forKey:@"PID"];
    [_ringtone setObject:[JFTHUtilities randomizedRingtoneParameter:JFTHRingtoneGUID] forKey:@"GUID"];
    
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with data: %@\"}", _ringtone);
    
    return self;
}

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

- (NSDictionary *)iTunesPlistRepresentation {
    NSMutableDictionary *tone;
    [tone setObject:[self guid] forKey:@"GUID"];
    [tone setObject:[self name] forKey:@"Name"];
    [tone setObject:[self pid] forKey:@"PID"];
    [tone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
    
    return tone;
}
- (NSDictionary *)dictionaryRepresentation {
    DDLogVerbose(@"{\"Ringtone init\":\"sending dict repr: %@\"}", _ringtone);
    return _ringtone;
}
- (void)initWithDictionary:(NSMutableDictionary *)dict {
    if (dict) {
        _ringtone = dict;
    }
}

@end
