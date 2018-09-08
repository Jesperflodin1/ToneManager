//
//  iOSHeaders.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#ifndef iOSHeaders_h
#define iOSHeaders_h


#endif /* iOSHeaders_h */

#import <MobileCoreServices/MobileCoreServices.h>

//@interface LSApplicationProxy
///*MobileCoreServices*/
//- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
//+ (id)applicationProxyForIdentifier:(NSString *)arg1;
//+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
//@end

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

@interface TLToneManager : NSObject
+(id)sharedToneManager;

//-(void)_loadITunesRingtoneInfoPlistAtPath:(id)arg1;
//-(void)_reloadTonesAfterExternalChange;
//-(void)_reloadITunesRingtonesAfterExternalChange; // ios 10
//-(NSMutableArray *)_tonesFromManifestPath:(id *)arg1 mediaDirectoryPath:(id *)arg2;

/*
 *  data: (NSData) ringtone data from file
 *  dict: (NSDictionary) keys="Name","Total Time","Purchased"=false,"Protected Content"=false
 *  block: (code block) receives arguments BOOL success and NSString toneIdentifier.
 *
 *  Imports the ringtone if Name does not already exist, generates an UUID and sets the success variable according to if import
 *  was successful or not and sets toneIdentifier to "itunes:UUID". The filename of the ringtone will be "import_UUID.m4r"
 *
 */
-(void)importTone:(NSData *)data metadata:(NSDictionary *)dict completionBlock:(void (^)(BOOL success, NSString *toneIdentifier))completionBlock;

// Pretty self-explanatory.
-(void)removeImportedToneWithIdentifier:(NSString *)toneIdentifier;

// Checks if the specified toneIdentifier exists in its plist and (i think) checks if the m4r file is playable.
// Returns YES if it exists and is playable, otherwise NO
-(BOOL)toneWithIdentifierIsValid:(NSString *)toneIdentifier;
@end
