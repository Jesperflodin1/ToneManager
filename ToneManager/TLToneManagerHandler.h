//
//  ToneLibraryHelper.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-07.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TLToneManagerHandler : NSObject

+ (TLToneManagerHandler *)sharedInstance;
- (void)importTone:(NSData *)data metadata:(NSDictionary *)dict completionBlock:(void (^)(BOOL, NSString *))completionBlock;
-(void)removeImportedToneWithIdentifier:(NSString *)toneIdentifier;
-(BOOL)toneWithIdentifierIsValid:(NSString *)toneIdentifier;

@end
