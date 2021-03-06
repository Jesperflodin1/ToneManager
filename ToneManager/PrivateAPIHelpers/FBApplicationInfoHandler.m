//
//  FBApplicationInfoHandler.m
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
    LSApplicationProxy *appProxy = [LSApplicationProxy performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    BFLog(@"JFTM: appProxy = %@",appProxy);
    FBApplicationInfo *appInfo = [[NSClassFromString(@"FBApplicationInfo") alloc] initWithApplicationProxy:appProxy];
    return [appInfo performSelector:@selector(dataContainerURL)];
}

+(NSURL *)sandboxURLForBundleIdentifier:(NSString * __nonnull)bundleID {
    LSApplicationProxy *appProxy = [self applicationProxyForBundleIdentifier:bundleID];
    FBApplicationInfo *appInfo = [[NSClassFromString(@"FBApplicationInfo") alloc] initWithApplicationProxy:appProxy];
    return [appInfo performSelector:@selector(sandboxURL)];
}
+(NSArray *)folderNamesForBundleIdentifier:(NSString * __nonnull)bundleID {
    LSApplicationProxy *appProxy = [self applicationProxyForBundleIdentifier:bundleID];
    FBApplicationInfo *appInfo = [[NSClassFromString(@"FBApplicationInfo") alloc] initWithApplicationProxy:appProxy];
    return [appInfo performSelector:@selector(folderNames)];
}
+(NSString *)fallbackFolderNameForBundleIdentifier:(NSString * __nonnull)bundleID {
    LSApplicationProxy *appProxy = [self applicationProxyForBundleIdentifier:bundleID];
    FBApplicationInfo *appInfo = [[NSClassFromString(@"FBApplicationInfo") alloc] initWithApplicationProxy:appProxy];
    return [appInfo performSelector:@selector(fallbackFolderName)];
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
    BFLog(@"Appproxy = %@", appProxy);
    return appProxy;
}


@end
