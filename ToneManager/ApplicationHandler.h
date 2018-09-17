//
//  ApplicationHandler.h
//  ToneManager
//
//  Created by Jesper Flodin on 2018-09-17.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplicationHandler : NSObject
  + (BOOL)openApplicationWithIdentifier:(NSString *)bundleID;
  
  @end
