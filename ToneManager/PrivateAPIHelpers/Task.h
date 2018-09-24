//
//  Task.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-24.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask : NSObject

- (instancetype __nonnull)init;
- (void)launch;
- (void)setArguments:(NSArray<NSString *> * __nullable)args;
- (void)setLaunchPath:(NSString * __nullable)path;
- (void)setStandardOutput:(id __nullable)output;
- (id __nullable)standardOutput;

@end
