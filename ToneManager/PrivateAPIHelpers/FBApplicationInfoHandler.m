//
//  FBApplicationInfoHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "FBApplicationInfoHandler.h"
#import <BugfenderSDK/BugfenderSDK.h>
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
//        BFLog(@"JFTM: FrontBoard Loaded!");
        return YES;
    } else {
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoard.framework"];
        if (![bundle load]) {
            BFLogErr(@"JFTM: ERROR: Failed to load FrontBoard framework");
            return NO;
        } else {
            BFLog(@"JFTM: FrontBoard Loaded from disk!");
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
        BFLogErr(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return nil;
    }
    FBApplicationInfo *appInfo = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    BFLog(@"JFTM: appInfo = %@",appInfo);
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
        BFLogErr(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return nil;
    }
    LSApplicationProxy *appProxy = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
//    BFLog(@"JFTM: appProxy = %@",appProxy);
    return [appProxy performSelector:@selector(itemName)];
}
    
+ (BOOL)installedStatusForBundleId:(NSString * __nonnull)bundleID {
    if (![FBApplicationInfoHandler loadFramework]) {
        return false;
    }
    if ( ![NSClassFromString(@"LSApplicationProxy") respondsToSelector:@selector(applicationProxyForIdentifier:)]) {
        BFLogErr(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return false;
    }
    LSApplicationProxy *appProxy = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    return (BOOL)[appProxy performSelector:@selector(isInstalled)];
}



//newerbetterfasterstronger
+(LSApplicationProxy *)applicationProxyForBundleIdentifier:(NSString *)bundleID {
    if (![FBApplicationInfoHandler loadFramework]) {
        return false;
    }
    if ( ![NSClassFromString(@"LSApplicationProxy") respondsToSelector:@selector(applicationProxyForIdentifier:)]) {
        BFLogErr(@"JFTM: ERROR: applicationProxyForIdentifier: not responding");
        return false;
    }
    LSApplicationProxy *appProxy = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    return appProxy;
}


@end
