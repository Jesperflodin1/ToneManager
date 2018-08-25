//
//  JFTHiOSHeaders.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-25.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

@interface PreferencesAppController : UIApplication
@end

@interface NSPathStore2 : NSString
@end

@interface TLITunesTone : NSObject
-(id)initWithPropertyListRepresentation:(id)arg1 filePath:(id)arg2;
@end

@interface TLToneManager : NSObject
+(id)sharedToneManager;
-(void)_loadITunesRingtoneInfoPlistAtPath:(id)arg1;
-(void)_reloadTonesAfterExternalChange;
-(void)_reloadITunesRingtonesAfterExternalChange; // ios 10
-(NSMutableArray *)_tonesFromManifestPath:(NSPathStore2 *)arg1 mediaDirectoryPath:(NSPathStore2 *)arg2;
@end

@interface TKTonePickerController : NSObject
-(void)_reloadTones;
-(void)_reloadMediaItems;
@end
@interface TKTonePickerViewController : UITableViewController {
    TKTonePickerController* _tonePickerController;
}
@end



@interface LSApplicationProxy
/*MobileCoreServices*/
- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
+ (id)applicationProxyForIdentifier:(NSString *)arg1;
+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
@end


/*
 @interface SpringBoard : UIApplication {
 dispatch_source_t _source;
 NSArray* mFiles;
 NSString* mPath;
 }
 @end*/

/*@interface FBApplicationInfo : NSObject
 - (NSURL *)dataContainerURL;
 - (NSURL *)bundleURL;
 - (NSString *)bundleIdentifier;
 - (NSString *)bundleType;
 - (NSString *)bundleVersion;
 - (NSString *)displayName;
 - (id)initWithApplicationProxy:(id)arg1;
 @end*/
