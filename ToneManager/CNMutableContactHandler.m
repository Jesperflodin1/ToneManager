//
//  CNContactHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-20.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "CNMutableContactHandler.h"
#import <Contacts/Contacts.h>
#import <BugfenderSDK/BugfenderSDK.h>
#import "iOSHeaders.h"

@implementation CNMutableContactHandler
    
    CNMutableContact * contact = nil;
    
-(instancetype)initWithContact:(CNContact *)cncontact {
    if (!(self = [super init])) {
        return nil;
    }
    contact = [cncontact mutableCopy];
    return self;
}
    
-(BOOL)setCallAlert:(NSString *)toneIdentifier {
    
    CNActivityAlert *alert = [[CNActivityAlert alloc] initWithSound:toneIdentifier vibration:0 ignoreMute:false];
    
    [contact performSelector:@selector(setCallAlert:) withObject:alert];
    return [self save];
    
}
-(BOOL)setTextAlert:(NSString *)toneIdentifier {
    
    CNActivityAlert *alert = [[CNActivityAlert alloc] initWithSound:toneIdentifier vibration:0 ignoreMute:false];
    
    [contact performSelector:@selector(setTextAlert:) withObject:alert];
    return [self save];
}

-(BOOL)save {
    CNContactStore *store = [[CNContactStore alloc] init];
    CNSaveRequest *request = [CNSaveRequest new];
    
    [request updateContact:contact];
    NSError *error;
    if ( ![store executeSaveRequest:request error:&error] ) {
        BFLogErr(@"Error when send save request for contact, error: %@", error);
        NSLog(@"Error when send save request for contact, error: %@", error);
        return NO;
    }
    
    return YES;
}
@end
