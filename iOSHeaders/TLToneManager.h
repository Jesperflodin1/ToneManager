//
//  TLToneManager.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-08-31.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

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
