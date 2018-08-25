//
//  JFTHUtilities.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHUtilities.h"

@implementation JFTHUtilities

+ (void)createFolders {
    DDLogDebug(@"{\"Foldercreator\":\"Preparing folders\"}");
    
    NSError *dirError;
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/iTunes/"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&dirError]) {
        DDLogError(@"{\"Foldercreator\":\"Error creating ringtones folder: %@\"}",dirError);
    } else
        DDLogDebug(@"{\"Foldercreator\":\"Success itunes folder\"}");
    
    NSError *ITdirError;
    if (![localFileManager createDirectoryAtPath:@"/var/mobile/Media/iTunes_Control/Ringtones"
                     withIntermediateDirectories:YES
                                      attributes:nil
                                           error:&ITdirError]) {
        DDLogError(@"{\"Foldercreator\":\"Error creating Ringtone folder:%@\"}",ITdirError);
    } else
        DDLogDebug(@"{\"Foldercreator\":\"Success ringtones folder\"}");
    
    DDLogVerbose(@"{\"Foldercreator\":\"Firstrun done\"}");
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
