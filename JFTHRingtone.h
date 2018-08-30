//
//  JFTHRingtone.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};

@interface JFTHRingtone : NSObject<NSCoding> {
    NSString *_fileName;
}

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSString *oldFileName;
@property (nonatomic, readonly) NSString *bundleID;
@property (nonatomic, readonly) NSString *md5;
@property (nonatomic, readonly) int64_t pid;
@property (nonatomic, readonly) NSString *guid;
@property (nonatomic, readonly) long totalTime;

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                         md5:(NSString *)md5
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID
                         pid:(int64_t)pid
                        guid:(NSString *)guid;

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                         md5:(NSString *)md5
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID;

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID;

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName;

- (BOOL)isEqualToRingtone:(JFTHRingtone *)tone;
- (BOOL)isEqualToJFTHRingtone:(JFTHRingtone *)tone;

- (NSDictionary *)iTunesPlistRepresentation;

+ (long)totalTimeForRingtoneFilePath:(NSString *)filePath;
+ (NSString *)md5ForRingtoneFilePath:(NSString *)filePath;
+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;
+ (NSString *)createNameFromFile:(NSString *)file;

//- (BOOL)isEqual:(id)object;

@end
