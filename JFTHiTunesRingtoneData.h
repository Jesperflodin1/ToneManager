//
//  JFTHiTunesRingtoneData.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFTHiTunesRingtoneData : NSObject

@property (nonatomic) BOOL isWritable;

- (void)loadRingtonesPlist;
- (void)saveRingtonesPlist;

- (NSDictionary *)getITunesRingtoneWithGUID:(NSString *)guid;
- (NSDictionary *)getITunesRingtoneWithName:(NSString *)name;
- (NSDictionary *)itunesRingtones;

- (void)removeDuplicatesInItunesPlistOf:(NSString *)name;

- (void)deleteRingtoneFromITunesPlist:(NSString *)file;
- (void)addRingtoneToITunesPlist:(NSDictionary *)tone fileName:(NSString *)file;
@end
