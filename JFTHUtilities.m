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
@end
