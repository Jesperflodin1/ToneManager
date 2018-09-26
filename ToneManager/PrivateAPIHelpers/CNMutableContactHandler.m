//
//  CNContactHandler.m
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-20.
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
        BFLogErr(@"Error when sending save request for contact, error: %@", error);
        NSLog(@"Error when sending save request for contact, error: %@", error);
        return NO;
    }
    
    return YES;
}
@end
