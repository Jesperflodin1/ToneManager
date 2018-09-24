//
//  FBApplicationInfoHandler.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 <#Description#>
 */
@interface FBApplicationInfoHandler : NSObject

/**
 <#Description#>

 @param bundleID <#bundleID description#>
 @return <#return value description#>
 */
+ (NSURL * __nullable)pathForBundleIdentifier:(NSString * __nonnull)bundleID;
/**
 <#Description#>

 @param bundleID <#bundleID description#>
 @return <#return value description#>
 */
+ (NSString * __nullable)displayNameForBundleIdentifier:(NSString * __nonnull)bundleID;
    
+ (BOOL)installedStatusForBundleId:(NSString * __nonnull)bundleID;
    
/**
 <#Description#>

 @return <#return value description#>
 */
+ (BOOL)loadFramework;

@end
