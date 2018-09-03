//
//  JFTHRingtoneInstaller.m
//  ToneHelper
//
//  Created by Jesper Flodin on 2018-09-03.
//  Copyright © 2018 Jesper Flodin. All rights reserved.
//

#import "JFTHRingtoneInstaller.h"
#import "JFTHRingtoneScanner.h"
#import "JFTHRingtoneDataController.h"
#import "JFTHCommonHeaders.h"
#import "JFTHiOSHeaders.h"

@interface JFTHRingtoneInstaller () {
    NSMutableArray<NSDictionary *> *_ringtonesToImport;
}

@property (nonatomic) JFTHRingtoneScanner *scanner;
@property (nonatomic) JFTHRingtoneDataController *dataController;

@end

@implementation JFTHRingtoneInstaller

- (instancetype)init {
    if (self = [super init]) {
        self.dataController = [JFTHRingtoneDataController new];
        self.scanner = [JFTHRingtoneScanner new];
        [self.scanner setInstaller:self];
        [self.dataController setInstaller:self];
        
        _ringtonesToImport = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    DDLogDebug(@"{\"RingtoneInstaller\":\"Deallocating installer\"}");
}

- (JFTHRingtoneDataController *)dataController {
    return _dataController;
}
- (JFTHRingtoneScanner *)scanner {
    return _scanner;
}

- (void)addRingtoneToImport:(NSDictionary *)tone {
    DDLogVerbose(@"{\"Ringtone Import\":\"Adding tone to import array: %@\"}", tone);
    [_ringtonesToImport addObject:tone];
}

- (void)scanDone {
    DDLogDebug(@"{\"Ringtone Import\":\"Scan done.\"}");
    if ([_ringtonesToImport count] > 0) {
        [_dataController setRingtonesToImport:_ringtonesToImport];
        [self.dataController startImport];
    } else
        DDLogDebug(@"{\"Ringtone Import\":\"Scan done. Found nothing to import.\"}");
}

- (void)installAllNewRingtonesFromAppsWithSubdirs:(NSDictionary *)apps { // scan for tones and install
    if ([apps count] > 0) {
        DDLogVerbose(@"{\"Ringtone Import\":\"Install called for apps: %@\"}", apps);
        [_scanner importNewRingtonesFromSubfoldersInApps:apps];
    }
}
- (void)installRingtone:(NSString *)fullPath { // install single tone
    DDLogDebug(@"{\"Ringtone Import\":\"Install called for single tone at path: %@\"}", fullPath);
    [_dataController importTone:fullPath fromBundleID:[[NSBundle mainBundle] bundleIdentifier] toneName:nil];
}

@end
