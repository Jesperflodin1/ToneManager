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

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *fileName;
@property (nonatomic) NSString *oldFileName;
@property (nonatomic) NSString *bundleID;
@property (nonatomic) NSString *md5;
@property (nonatomic) int64_t pid;
@property (nonatomic) NSString *guid;
@property (nonatomic) long totalTime;

- (instancetype)initWithName:(NSString *)name
                    fileName:(NSString *)fileName
                 oldFileName:(NSString *)oldFileName
                    bundleID:(NSString *)bundleID;

- (void)setFileName:(NSString *)fileName;
- (NSString *)fileName;

- (NSDictionary *)iTunesPlistRepresentation;
- (void)initWithDictionary:(NSMutableDictionary *)dict;

+ (int)totalTimeForRingtoneFilePath:(NSString *)filePath;
+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;

//- (BOOL)isEqual:(id)object;

@end
