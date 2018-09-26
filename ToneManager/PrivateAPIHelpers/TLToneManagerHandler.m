//
//  ToneLibraryHelper.m
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

-(void)setCurrentToneIdentifier:(NSString *)identifier forAlertType:(long long)alertType {
    [_toneManager setCurrentToneIdentifier:identifier forAlertType:alertType];
}

-(NSString * __nullable)filePathForToneIdentifier:(NSString * __nonnull)identifier  {
    return [_toneManager filePathForToneIdentifier:identifier];
}
-(NSString * __nullable)currentToneIdentifierForAlertType:(long long)alertType {
    return [_toneManager currentToneIdentifierForAlertType:alertType];
}

-(NSString * __nullable)nameForToneIdentifier:(NSString * __nonnull)identifier {
    return [_toneManager nameForToneIdentifier:identifier];
}

-(NSString * __nullable)_toneIdentifierForFileAtPath:(NSString * __nonnull)path; {
    BOOL valid;
    NSString *identifier = [_toneManager _toneIdentifierForFileAtPath:path isValid:&valid];
    if (valid) {
        return identifier;
    }
    else {
        return nil;
    }
}
@end
