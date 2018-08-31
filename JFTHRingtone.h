//
//  JFTHRingtone.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface JFTHRingtone : NSObject<NSCoding>

@property (nonatomic, readonly) NSString *name;
@property (nonatomic) NSString *toneIdentifier;
@property (nonatomic, readonly) NSString *filePath;
@property (nonatomic, readonly) NSString *bundleID;
@property (nonatomic, readonly) NSString *md5;
@property (nonatomic, readonly) long totalTime;

@property (nonatomic, readonly) BOOL isValid;

- (instancetype)initWithName:(NSString *)name
                    filePath:(NSString *)filePath
                         md5:(NSString *)md5
                    bundleID:(NSString *)bundleID;

- (instancetype)initWithName:(NSString *)name
                    filePath:(NSString *)filePath
                    bundleID:(NSString *)bundleID;

- (BOOL)isEqualToRingtone:(JFTHRingtone *)tone;
- (BOOL)isEqualToJFTHRingtone:(JFTHRingtone *)tone;

+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath;
+ (NSString *)md5ForRingtoneFilePath:(NSString *)filePath;
+ (NSString *)createNameFromFile:(NSString *)file;

//- (BOOL)isEqual:(id)object;

@end
