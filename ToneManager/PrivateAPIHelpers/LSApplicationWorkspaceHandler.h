//
//  ApplicationHandler.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSApplicationWorkspaceHandler : NSObject
  +(BOOL)openApplicationWithBundleID:(NSString *)bundleID;
  +(BOOL)registerApplicationDictionary;

+(BOOL)unregisterApplication:(NSURL *)url;
+(BOOL)registerApplication:(NSURL *)url;

+(BOOL)invalidateIconCache:(NSString *)bundleID;
    
+(BOOL)openSensitiveURL:(NSURL *)url;
@end
