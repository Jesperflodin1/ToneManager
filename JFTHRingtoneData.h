//
//  JFTHRingtoneData.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHHeaders.h"
#import "JFTHRingtone.h"
#import "JFTHConstants.h"

@interface JFTHRingtoneData : NSObject


- (void)addRingtone:(JFTHRingtone *)ringtone;
- (JFTHRingtone *)deleteRingtoneWithGuid:(NSString *)toneGUID;
- (void)deleteRingtoneWithFileName:(NSString *)FileName;

- (NSMutableDictionary *)importedTones;
- (JFTHRingtone *)getRingtoneWithGUID:(NSString *)toneGUID;
- (JFTHRingtone *)getRingtoneWithHash:(NSString *)md5;
- (JFTHRingtone *)getRingtoneWithName:(NSString *)name;

- (NSDictionary *)iTunesPlistRepresentation;
@end
