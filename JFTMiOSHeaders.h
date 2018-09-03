//
//  JFTMiOSHeaders.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <UIKit/UIApplication.h>

@interface PreferencesAppController : UIApplication
@end

@interface LSApplicationProxy
/*MobileCoreServices*/
- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
+ (id)applicationProxyForIdentifier:(NSString *)arg1;
+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
@end

@interface FBApplicationInfo : NSObject
/*FrontBoard*/
 - (NSURL *)dataContainerURL;
 - (NSURL *)bundleURL;
 - (NSString *)bundleIdentifier;
 - (NSString *)bundleType;
 - (NSString *)bundleVersion;
 - (NSString *)displayName;
 - (id)initWithApplicationProxy:(id)arg1;
 @end
@interface SpringBoard : UIApplication
@end

