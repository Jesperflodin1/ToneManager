//
//  JFTHRingtone.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHRingtone.h"
#import "JFTHCommonHeaders.h"
#import "FileHash.h"
#import "JFTHConstants.h"

@implementation JFTHRingtone
#pragma mark - Init methods
- (instancetype)init {
    if (!(self = [super init]))
        return self;
    
    return self;
}

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID
{
    if (!(self = [super init]))
        return self;
    //TODO: Get total time
    _name = name;
    _fileName = fileName;
    
    _md5 = [FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:fileName]];
    
    _oldFileName = oldFileName;
    _bundleID = bundleID;
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc]init];
    NSNumber *  number = [numberFormatter numberFromString:[JFTHRingtone randomizedRingtoneParameter:JFTHRingtonePID]];
    _pid = number.longLongValue;
    _guid = [JFTHRingtone randomizedRingtoneParameter:JFTHRingtoneGUID];
    
    DDLogVerbose(@"{\"Ringtone init\":\"tone initialized: %@\"}", self.fileName);
    
    return self;
}

- (void)initWithDictionary:(NSMutableDictionary *)dict {
    if (dict) {
        if (![dict objectForKey:@"Total Time"]) {
            // TODO: Get total time
        }
        //_ringtone = dict;
    }
}
#pragma mark - NSCoding methods
- (id)initWithCoder:(NSCoder *)coder;{
    if ((self = [super init]))
    {
        _name = [coder decodeObjectForKey:@"name"];
        _fileName = [coder decodeObjectForKey:@"fileName"];
        _oldFileName = [coder decodeObjectForKey:@"oldFileName"];
        _bundleID = [coder decodeObjectForKey:@"bundleID"];
        _md5 = [coder decodeObjectForKey:@"md5"];
        _pid = [coder decodeInt64ForKey:@"pid"];
        _guid = [coder decodeObjectForKey:@"guid"];
        _totalTime = [coder decodeIntegerForKey:@"totalTime"];
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder;{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_fileName forKey:@"fileName"];
    [coder encodeObject:_oldFileName forKey:@"oldFileName"];
    [coder encodeObject:_bundleID forKey:@"bundleID"];
    [coder encodeObject:_md5 forKey:@"md5"];
    [coder encodeInt64:_pid forKey:@"pid"];
    [coder encodeObject:_guid forKey:@"guid"];
    [coder encodeInteger:_totalTime forKey:@"totalTime"];
}

#pragma mark - Comparisons
- (BOOL)isEqual:(id)object {
    
}
-(NSUInteger) hash
{
    return [self.md5 hash];
}


#pragma mark - Setters
- (void)setFileName:(NSString *)fileName {
    _fileName = fileName;
    
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with file: %@\"}", fileName);
    NSString *md5 = [FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:fileName]];
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with hash: %@\"}", md5);
    _md5 = md5;
    DDLogVerbose(@"{\"Ringtone init\":\"init tone with hash: %@\"}", self.md5);
}

#pragma mark - Getters
- (NSString *)fileName {
    return _fileName;
}

#pragma mark - Converts to format ToneLibrary understands
- (NSDictionary *)iTunesPlistRepresentation {
    NSMutableDictionary *tone;
    [tone setObject:self.guid forKey:@"GUID"];
    [tone setObject:self.name forKey:@"Name"];
    [tone setObject:[NSNumber numberWithLongLong:self.pid] forKey:@"PID"];
    [tone setObject:[NSNumber numberWithLong:self.totalTime] forKey:@"Total Time"]; //callservicesd craps itself if this is missing
    [tone setObject:[NSNumber numberWithBool:NO] forKey:@"Protected Content"];
    
    return tone;
}

#pragma mark - Methods for calculated values
+ (int)totalTimeForRingtoneFilePath:(NSString *)filePath {
    // TODO: CODE
    return 1;
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
