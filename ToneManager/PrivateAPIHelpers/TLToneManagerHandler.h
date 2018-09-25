//
//  ToneLibraryHelper.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 <#Description#>
 */
@interface TLToneManagerHandler : NSObject

/**
 <#Description#>

 @return <#return value description#>
 */
+ (TLToneManagerHandler *)sharedInstance;
/**
 <#Description#>

 @param data <#data description#>
 @param dict <#dict description#>
 @param completionBlock <#completionBlock description#>
 */
- (void)importTone:(NSData *)data metadata:(NSDictionary *)dict completionBlock:(void (^)(BOOL, NSString *))completionBlock;
/**
 <#Description#>

 @param toneIdentifier <#toneIdentifier description#>
 */
-(void)removeImportedToneWithIdentifier:(NSString *)toneIdentifier;
/**
 <#Description#>

 @param toneIdentifier <#toneIdentifier description#>
 @return <#return value description#>
 */
-(BOOL)toneWithIdentifierIsValid:(NSString *)toneIdentifier;

-(BOOL)canImport;
    
-(void)setCurrentToneIdentifier:(NSString *)identifier forAlertType:(long long)alertType ;

-(NSString * __nullable)filePathForToneIdentifier:(NSString * __nonnull)identifier;
-(NSString * __nullable)currentToneIdentifierForAlertType:(long long)alertType;

-(NSString * __nullable)nameForToneIdentifier:(NSString * __nonnull)identifier;

-(NSString * __nullable)_toneIdentifierForFileAtPath:(NSString * __nonnull)path;

@end