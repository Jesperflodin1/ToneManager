//
//  CNContactHandler.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-20.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CNActivityAlert, CNContact;

@interface CNMutableContactHandler : NSObject
    
-(instancetype)initWithContact:(CNContact *)cncontact;
    
-(BOOL)setCallAlert:(NSString *)toneIdentifier ;
-(BOOL)setTextAlert:(NSString *)toneIdentifier ;
-(BOOL)save;
@end
