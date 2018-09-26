//
//  ApplicationHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
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

    return [_workspace invalidateIconCache:bundleID];
}

+(BOOL)unregisterApplication:(NSURL *)url {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];

    return [_workspace unregisterApplication:url];
}
+(BOOL)registerApplication:(NSURL *)url {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];

    return [_workspace registerApplication:url];
}
    
+(BOOL)openSensitiveURL:(NSURL *)url {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    return [_workspace openSensitiveURL:url withOptions:nil];
}
+(NSArray* __nullable)allInstalledApplications {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    return [_workspace allInstalledApplications];
}
+(NSArray* __nullable)applicationsOfType:(unsigned long long)arg1 {
    PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") performSelector:@selector(defaultWorkspace)];
    return [_workspace applicationsOfType:arg1];
}
@end
