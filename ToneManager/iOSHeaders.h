//
//  iOSHeaders.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <UIKit/UIApplication.h>

//#import <MobileCoreServices/MobileCoreServices.h>

/**
 <#Description#>
 */
@interface LSApplicationProxy : NSObject
/*MobileCoreServices*/
- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
+ (id)applicationProxyForIdentifier:(NSString *)arg1;
+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
- (NSString *)itemName;
- (BOOL)isInstalled;
@end

/**
 <#Description#>
 */
@interface FBApplicationInfo : NSObject
/*FrontBoard*/
- (NSURL *)dataContainerURL;
- (NSURL *)bundleURL;
- (NSString *)bundleIdentifier;
- (NSString *)bundleType;
- (NSString *)bundleVersion;
- (id)initWithApplicationProxy:(id)arg1;
@end

/**
 <#Description#>
 */
@interface TLToneManager : NSObject
/**
 <#Description#>

 @return <#return value description#>
 */
+(id)sharedToneManager;

/**
 Imports the ringtone if Name does not already exist, generates an UUID and sets the success variable according to if import was successful or not and sets toneIdentifier to "itunes:UUID". The filename of the ringtone will be "import_UUID.m4r"

 @param data (NSData) ringtone data from file
 @param dict (NSDictionary) keys="Name","Total Time","Purchased"=false,"Protected Content"=false
 @param completionBlock (code block) receives arguments BOOL success and NSString toneIdentifier.
 */
-(void)importTone:(NSData *)data metadata:(NSDictionary *)dict completionBlock:(void (^)(BOOL success, NSString *toneIdentifier))completionBlock;

// Pretty self-explanatory.
/**
 <#Description#>

 @param toneIdentifier <#toneIdentifier description#>
 */
-(void)removeImportedToneWithIdentifier:(NSString *)toneIdentifier;

// Checks if the specified toneIdentifier exists in its plist and (i think) checks if the m4r file is playable.
// Returns YES if it exists and is playable, otherwise NO
/**
 <#Description#>

 @param toneIdentifier <#toneIdentifier description#>
 @return <#return value description#>
 */
-(BOOL)toneWithIdentifierIsValid:(NSString *)toneIdentifier;
@end


@interface PrivateApi_LSApplicationWorkspace : NSObject
+(id)defaultWorkspace;
- (NSArray*)allInstalledApplications;
- (bool)openApplicationWithBundleID:(id)arg1;
-(BOOL)unregisterApplication:(NSURL *)url;
-(BOOL)registerApplication:(NSURL *)url;
-(BOOL)registerApplicationDictionary:(id)arg1;
-(BOOL)registerBundleWithInfo:(id)arg1 options:(id)arg2 type:(unsigned long long)arg3 progress:(id)arg4;
-(BOOL)_LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)arg1 internal:(BOOL)arg2 user:(BOOL)arg3;
-(BOOL)invalidateIconCache:(id)arg1 ;
@end
