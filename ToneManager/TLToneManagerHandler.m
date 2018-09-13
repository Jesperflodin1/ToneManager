//
//  ToneLibraryHelper.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "TLToneManagerHandler.h"
#import "iOSHeaders.h"

/**
 <#Description#>
 */
@implementation TLToneManagerHandler

static TLToneManager *_toneManager = nil;
static TLToneManagerHandler *_helper = nil;

/**
 <#Description#>

 @return <#return value description#>
 */
+ (TLToneManagerHandler  * __nullable )sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ToneLibrary.framework"];
        
        if (![bundle load]) {
            NSLog(@"ERROR: Failed to load ToneLibrary framework");
        } else {
            _toneManager = [NSClassFromString(@"TLToneManager") performSelector:@selector(sharedToneManager)];
            _helper = [[TLToneManagerHandler alloc] init];
        }
    });
    
    return _helper;
}

-(BOOL)canImport {
    BOOL result;
    if ([_toneManager respondsToSelector:@selector(importTone:metadata:completionBlock:)]) {
        result = [_toneManager respondsToSelector:@selector(removeImportedToneWithIdentifier:)];
    }
    else {
        result = NO;
    }
    return result;
}

/**
 <#Description#>

 @param toneIdentifier <#toneIdentifier description#>
 @return <#return value description#>
 */
- (BOOL)toneWithIdentifierIsValid:(NSString * _Nonnull )toneIdentifier {
    return [_toneManager toneWithIdentifierIsValid:toneIdentifier];
}

/**
 <#Description#>

 @param toneIdentifier <#toneIdentifier description#>
 */
- (void)removeImportedToneWithIdentifier:(NSString * _Nonnull)toneIdentifier {
    [_toneManager removeImportedToneWithIdentifier:toneIdentifier];
}

/**
 <#Description#>

 @param data <#data description#>
 @param dict <#dict description#>
 @param completionBlock <#completionBlock description#>
 */
- (void)importTone:(NSData * _Nonnull)data metadata:(NSDictionary * _Nonnull)dict completionBlock:(void (^)(BOOL, NSString * __nullable))completionBlock {
    [_toneManager importTone:data metadata:dict completionBlock:completionBlock];
}

@end
