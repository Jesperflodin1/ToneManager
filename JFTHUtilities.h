//
//  JFTHUtilities.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHHeaders.h"

typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};


@interface JFTHUtilities : NSObject

+ (void)createFolders;
+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;

@end
