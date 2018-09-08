//
//  FBApplicationInfoHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "FBApplicationInfoHandler.h"
#import "iOSHeaders.h"

@implementation FBApplicationInfoHandler

+ (BOOL)loadFramework {
    if (NSClassFromString(@"FBApplicationInfo")) {
        NSLog(@"FrontBoard Loaded!");
        return YES;
    } else {
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/FrontBoard.framework"];
        if (![bundle load]) {
            NSLog(@"ERROR: Failed to load FrontBoard framework");
            return NO;
        } else {
            NSLog(@"FrontBoard Loaded from disk!");
            return YES;
        }
    }
}

+ (NSURL * _Nullable )pathForBundleIdentifier:(NSString *)bundleID {
    if (![FBApplicationInfoHandler loadFramework]) {
        return nil;
    }
//    SEL selector = NSSelectorFromString(@"applicationProxyForIdentifier:");
    if ( ![NSClassFromString(@"LSApplicationProxy") respondsToSelector:@selector(applicationProxyForIdentifier:)]) {
        NSLog(@"ERROR: applicationProxyForIdentifier: not responding");
        return nil;
    }
    Class FBAppInfo = NSClassFromString(@"FBApplicationInfo");
    NSLog(@"FBAppInfo = %@",FBAppInfo);
    FBApplicationInfo *appInfo = [NSClassFromString(@"LSApplicationProxy") performSelector:@selector(applicationProxyForIdentifier:) withObject:bundleID];
    NSLog(@"appInfo = %@",appInfo);
    return [appInfo performSelector:@selector(dataContainerURL)];
}

@end
