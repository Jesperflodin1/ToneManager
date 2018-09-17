//
//  ApplicationHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "ApplicationHandler.h"
#import "iOSHeaders.h"

@implementation ApplicationHandler : NSObject
+ (BOOL)openApplicationWithIdentifier:(NSString *)bundleID {
  PrivateApi_LSApplicationWorkspace* _workspace = [NSClassFromString(@"LSApplicationWorkspace") new];
  
  return (BOOL)[_workspace openApplicationWithBundleID:bundleID];
}
  
@end
