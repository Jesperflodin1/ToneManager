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
#import "JFTHiOSHeaders.h"

@implementation JFTHRingtone
#pragma mark - Init methods
- (instancetype)init {
    if (!(self = [super init]))
        return self;
    
    return self;
}

- (instancetype)initWithName:(NSString *)name
                    filePath:(NSString *)filePath
                         md5:(NSString *)md5
                    bundleID:(NSString *)bundleID
{
    if (!(self = [super init]))
        return self;
    
    _name = name;
    _filePath = filePath;
    _bundleID = bundleID;
    _md5 = md5;
    
    //TODO: Get total time
    _totalTime = [JFTHRingtone totalTimeForRingtoneFilePath:filePath];
    
    _isValid = YES;
    
    DDLogVerbose(@"{\"Ringtone init\":\"tone initialized: %@\"}", self);
    return self;
}
- (instancetype)initWithName:(NSString *)name
                    filePath:(NSString *)filePath
                    bundleID:(NSString *)bundleID
{
    return [self initWithName:name
                     filePath:filePath
                          md5:[JFTHRingtone md5ForRingtoneFilePath:filePath]
                     bundleID:bundleID];
}

#pragma mark - NSCoding methods
- (id)initWithCoder:(NSCoder *)coder;{
    if ((self = [super init]))
    {
        _name = [coder decodeObjectForKey:@"name"];
        _filePath = [coder decodeObjectForKey:@"filePath"];
        _toneIdentifier = [coder decodeObjectForKey:@"toneIdentifier"];
        _bundleID = [coder decodeObjectForKey:@"bundleID"];
        _md5 = [coder decodeObjectForKey:@"md5"];
        _totalTime = [coder decodeIntegerForKey:@"totalTime"];
        
        // ask TLToneManager if toneidentifier is valid (= is imported)
        if (!NSClassFromString(@"TLToneManager")) {
            DDLogInfo(@"{\"Ringtone info\":\"TLToneManager missing, loading framework\"}");
            dlopen("/System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary", RTLD_LAZY);
        }
        TLToneManager *toneMan;
        if ([toneMan respondsToSelector:@selector(toneWithIdentifierIsValid:)]) {
            if ([toneMan toneWithIdentifierIsValid:_toneIdentifier]) {
                _isValid = YES;
            } else {
                _isValid = NO;
            }
        }
        
        // check if file exists in appdir?
    }
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder;{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_filePath forKey:@"filePath"];
    [coder encodeObject:_toneIdentifier forKey:@"toneIdentifier"];
    [coder encodeObject:_bundleID forKey:@"bundleID"];
    [coder encodeObject:_md5 forKey:@"md5"];
    [coder encodeInteger:_totalTime forKey:@"totalTime"];
}

#pragma mark - Comparisons
- (BOOL)isEqual:(id)object {
    if (self == object)
        return YES;
    
    if (![object isKindOfClass:[JFTHRingtone class]]) {
        return NO;
    }
    
    return [self isEqualToJFTHRingtone:object];
}
- (BOOL)isEqualToRingtone:(JFTHRingtone *)tone {
    return [self isEqualToJFTHRingtone:tone];
}
- (BOOL)isEqualToJFTHRingtone:(JFTHRingtone *)tone {
    DDLogVerbose(@"{\"Ringtone info\":\"comparing ringtone parameter identifier: %@\"}", self.toneIdentifier);
    return [self.toneIdentifier isEqualToString:tone.toneIdentifier];
}
-(NSUInteger) hash
{
    return [self.toneIdentifier hash];
}

#pragma mark - Methods for calculated values
+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath {
    // TODO: CODE
    return 123456;
}
+ (NSString *)md5ForRingtoneFilePath:(NSString *)filePath {
    return [FileHash md5HashOfFileAtPath:filePath];
}

+ (NSString *)createNameFromFile:(NSString *)file {
    // Create Ringtone Name to show in ringtone picker list. Remove "ugly" characters first
    NSString *baseName = [file stringByDeletingPathExtension];
    NSCharacterSet *doNotWant = [[NSCharacterSet characterSetWithCharactersInString:@" ABCDEFGHIJKLMNOPQRSTUVWXYZÅÄÖabcdefghijklmnopqrstuvwxyzåäö0123456789._-"] invertedSet];
    return [[baseName componentsSeparatedByCharactersInSet: doNotWant] componentsJoinedByString: @""];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<JFTHRingtone: %@ file: %@>",_name,_filePath];
}

@end
