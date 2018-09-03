//
//  JFTHRingtoneInstaller.h
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-09-03.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController, JFTHRingtoneScanner;

@interface JFTHRingtoneInstaller : NSObject

- (JFTHRingtoneDataController *)dataController;
- (JFTHRingtoneScanner *)scanner;

- (void)installAllNewRingtonesFromAppsWithSubdirs:(NSDictionary *)apps;
- (void)installRingtone:(NSString *)fullPath;


- (void)addRingtoneToImport:(NSDictionary *)tone;
- (void)scanDone;

@end
