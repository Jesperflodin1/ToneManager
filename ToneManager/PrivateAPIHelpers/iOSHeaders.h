//
//  iOSHeaders.h
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

-(id)iconDataForVariant:(int)arg1 ;
-(BOOL)isRemoveableSystemApp;
-(BOOL)isRestricted;
-(BOOL)isLaunchProhibited; //ios 10+
-(BOOL)isWhitelisted;
-(BOOL)isRemovedSystemApp;
-(NSString *)applicationType;
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
    
-(void)setCurrentToneIdentifier:(NSString *)arg1 forAlertType:(long long)arg2;

-(id)filePathForToneIdentifier:(id)arg1 ;
-(id)currentToneIdentifierForAlertType:(long long)arg1 ;
-(id)nameForToneIdentifier:(id)arg1 ;

-(id)_toneIdentifierForFileAtPath:(id)arg1 isValid:(BOOL*)arg2 ;
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
-(BOOL)openSensitiveURL:(id)arg1 withOptions:(id)arg2 ;
@end

@interface CNActivityAlert : NSObject
-(id)initWithSound:(id)arg1 vibration:(id)arg2 ignoreMute:(BOOL)arg3 ;
@end

