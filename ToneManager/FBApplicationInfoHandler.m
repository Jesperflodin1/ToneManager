//
//  FBApplicationInfoHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "FBApplicationInfoHandler.h"
#import "iOSHeaders.h"

/**
 <#Description#>
 */
@implementation FBApplicationInfoHandler

/**
 <#Description#>

 @return <#return value description#>
 */
+ (BOOL)loadFramework {
    if (NSClassFromString(@"FBApplicationInfo")) {
        NSLog(@"JFTM: FrontBoard Loaded!");
        return YES;
    } else {
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoard.framework"];
        if (![bundle load]) {
            NSLog(@"JFTM: ERROR: Failed to load FrontBoard framework");
            return NO;
        } else {
            NSLog(@"JFTM: FrontBoard Loaded from disk!");
            return YES;
        }
    }
}

/**
 <#Description#>

 @param bundleID <#bundleID description#>
 @return <#return value description#>
 */
+ (NSURL * _Nullable )pathForBundleIdentifier:(NSString *)bundleID {
    if (![FBApplicationInfoHandler loadFramework]) {
        return nil;
    }
//    SEL selector = NSSelectorFromString(@"applicationProxyForIdentifier:");
    if ( ![NSClassFromString(@"LSApplicationProxy") respondsToSelector:@selector(applicationProxyForIdentifier:)]) {
        NSLog(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return nil;
    }
    FBApplicationInfo *appInfo = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    NSLog(@"JFTM: appInfo = %@",appInfo);
    return [appInfo performSelector:@selector(dataContainerURL)];
}

/**
 <#Description#>

 @param bundleID <#bundleID description#>
 @return <#return value description#>
 */
+ (NSString * __nullable)displayNameForBundleIdentifier:(NSString * __nonnull)bundleID {
    if (![FBApplicationInfoHandler loadFramework]) {
        return nil;
    }
    //    SEL selector = NSSelectorFromString(@"applicationProxyForIdentifier:");
    if ( ![NSClassFromString(@"LSApplicationProxy") respondsToSelector:@selector(applicationProxyForIdentifier:)]) {
        NSLog(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return nil;
    }
    LSApplicationProxy *appProxy = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    NSLog(@"JFTM: appProxy = %@",appProxy);
    return [appProxy performSelector:@selector(itemName)];
}
    
+ (BOOL)installedStatusForBundleId:(NSString * __nonnull)bundleID {
    if (![FBApplicationInfoHandler loadFramework]) {
        return false;
    }
    if ( ![NSClassFromString(@"LSApplicationProxy") respondsToSelector:@selector(applicationProxyForIdentifier:)]) {
        NSLog(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return nil;
    }
    LSApplicationProxy *appProxy = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    return [appProxy performSelector:@selector(isInstalled)];
}

@end
