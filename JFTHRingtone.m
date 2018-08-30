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
                         md5:(NSString *)md5
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID
                         pid:(int64_t)pid
                        guid:(NSString *)guid
{
    if (!(self = [super init]))
        return self;
    
    //TODO: nsfilemanager contentsequalatpath faster than md5?
    _name = name;
    _fileName = fileName;
    _md5 = md5;
    _oldFileName = oldFileName;
    _bundleID = bundleID;
    _pid = pid;
    _guid = guid;
    
    //TODO: Get total time
    _totalTime = [JFTHRingtone totalTimeForRingtoneFilePath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:fileName]];
    
    DDLogVerbose(@"{\"Ringtone init\":\"tone initialized: %@\"}", self.fileName);
    return self;
}

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                         md5:(NSString *)md5
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID
{
    
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc]init];
    NSNumber *  number = [numberFormatter numberFromString:[JFTHRingtone randomizedRingtoneParameter:JFTHRingtonePID]];
    int64_t pid = number.longLongValue;
    NSString *guid = [JFTHRingtone randomizedRingtoneParameter:JFTHRingtoneGUID];
    
    return [self initWithName:name
                     fileName:fileName
                          md5:md5
                  oldFileName:oldFileName
                     bundleID:bundleID
                          pid:pid
                         guid:guid];
}

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID
{
    NSString *md5 = [FileHash md5HashOfFileAtPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:fileName]];
    return [self initWithName:name
                     fileName:fileName
                          md5:md5
                  oldFileName:oldFileName
                     bundleID:bundleID];
}

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
{
    return [self initWithName:name
                     fileName:fileName
                  oldFileName:nil
                     bundleID:nil];
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
    if (self == object)
        return YES;
    
    if (![object isKindOfClass:[NSArray class]]) {
        return NO;
    }
    
    return [self isEqualToJFTHRingtone:object];
}
- (BOOL)isEqualToRingtone:(JFTHRingtone *)tone {
    return [self isEqualToJFTHRingtone:tone];
}
- (BOOL)isEqualToJFTHRingtone:(JFTHRingtone *)tone {
    DDLogVerbose(@"{\"Ringtone info\":\"comparing ringtone parameters: self. %@\"}", self.fileName);
    return [self.guid isEqualToString:tone.guid];
}
-(NSUInteger) hash
{
    return [self.guid hash];
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
+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath {
    // TODO: CODE
    return 123456;
}
+ (NSString *)md5ForRingtoneFilePath:(NSString *)filePath {
    return [FileHash md5HashOfFileAtPath:filePath];
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

+ (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<JFTHRingtone: %@ file: %@ oldFileName:%@ pid: %lld guid:%@",_name,_fileName,_oldFileName,_pid,_guid];
}

@end
