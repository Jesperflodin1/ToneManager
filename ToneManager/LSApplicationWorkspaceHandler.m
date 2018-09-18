//
//  ApplicationHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "LSApplicationWorkspaceHandler.h"
#import "iOSHeaders.h"

@implementation LSApplicationWorkspaceHandler : NSObject
+ (BOOL)openApplicationWithBundleID:(NSString *)bundleID {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
  
    return (BOOL)[_workspace openApplicationWithBundleID:bundleID];
}

+(BOOL)registerApplicationDictionary {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    
    NSString *path = [[NSBundle mainBundle] bundlePath];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"Info.plist"]];
    [info setObject:path forKey:@"Path"];
    [info setObject:@"System" forKey:@"ApplicationType"];
    
    return (BOOL)[_workspace registerApplicationDictionary:info];
}

+(BOOL)invalidateIconCache:(NSString *)bundleID {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    NSLog(@"JFLOG: invalidate icon cache");
    return [_workspace invalidateIconCache:bundleID];
}

+(BOOL)unregisterApplication:(NSURL *)url {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    NSLog(@"JFLOG: unregister app");
    return [_workspace unregisterApplication:url];
}
+(BOOL)registerApplication:(NSURL *)url {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    NSLog(@"JFLOG: register app");
    
    
    return [_workspace registerApplication:url];
}
@end
