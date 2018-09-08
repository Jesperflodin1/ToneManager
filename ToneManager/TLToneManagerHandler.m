//
//  ToneLibraryHelper.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "TLToneManagerHandler.h"
#import "iOSHeaders.h"

@implementation TLToneManagerHandler

static TLToneManager *_toneManager = nil;
static TLToneManagerHandler *_helper = nil;

+ (TLToneManagerHandler *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle *bundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/ToneLibrary.framework"];
        
        if (![bundle load]) {
            NSLog(@"ERROR: Failed to load ToneLibrary framework");
        } else {
            _toneManager = [NSClassFromString(@"TLToneManager") valueForKey:@"sharedInstance"];
            _helper = [[TLToneManagerHandler alloc] init];
        }
    });
    
    return _helper;
}

- (BOOL)toneWithIdentifierIsValid:(NSString *)toneIdentifier {
    return [_toneManager toneWithIdentifierIsValid:toneIdentifier];
}

- (void)removeImportedToneWithIdentifier:(NSString *)toneIdentifier {
    [_toneManager removeImportedToneWithIdentifier:toneIdentifier];
}

- (void)importTone:(NSData *)data metadata:(NSDictionary *)dict completionBlock:(void (^)(BOOL, NSString *))completionBlock {
    [_toneManager importTone:data metadata:dict completionBlock:completionBlock];
}

@end
