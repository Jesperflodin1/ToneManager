//
//  FBApplicationInfoHandler.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//
//
//  MIT License
//
//  Copyright (c) 2018 Jesper Flodin
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import <Foundation/Foundation.h>
#import "iOSHeaders.h"


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
+(LSApplicationProxy *)applicationProxyForBundleIdentifier:(NSString *)bundleID;

//+(NSString *)itemName;
//+(BOOL)isInstalled;
//
//+(NSData *)iconDataForVariant:(int)variant;
//+(BOOL)isRemoveableSystemApp;
//+(BOOL)isRestricted;
//+(BOOL)isLaunchProhibited; //ios 10+
//+(BOOL)isWhitelisted;
//+(BOOL)isRemovedSystemApp;
//+(NSString *)applicationType;

@end
