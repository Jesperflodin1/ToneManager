//
//  FBApplicationInfoHandler.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FBApplicationInfoHandler : NSObject

+ (NSURL * __nullable)pathForBundleIdentifier:(NSString * __nonnull)bundleID;
+ (BOOL)loadFramework;

@end
