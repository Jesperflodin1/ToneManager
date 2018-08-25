//
//  JFTHRingtone.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface JFTHRingtone : NSObject

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID;

- (void)setName:(NSString *)name;
- (NSString *)name;

- (void)setFileName:(NSString *)fileName;
- (NSString *)fileName;

- (void)setOldFileName:(NSString *)oldFileName;
- (NSString *)oldFileName;

- (void)setBundleID:(NSString *)bundleID;
- (NSString *)bundleID;

- (void)setMd5:(NSString *)md5;
- (NSString *)md5;

- (void)setPID:(NSNumber *)pid;
- (NSNumber *)pid;

- (void)setGUID:(NSString *)guid;
- (NSString *)guid;

- (NSDictionary *)iTunesPlistRepresentation;
- (NSDictionary *)dictionaryRepresentation;
- (void)initWithDictionary:(NSMutableDictionary *)dict;

@end
