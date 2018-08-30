#import "JFTHRingtoneImporter.h"
#import "JFTHRingtoneDataController.h"
#import "JFTHCommonHeaders.h"
#import "JFTHiOSHeaders.h"
#import "JFTHRingtone.h"

#import "JFTHConstants.h"

//For md5 calculations
#include "FileHash.h"

//BOOL kWriteITunesRingtonePlist;

extern NSString *const HBPreferencesDidChangeNotification;

@interface JFTHRingtoneImporter () {
    NSMutableDictionary *_ringtonesToImport;
    BOOL _shouldImportRingtones;
    
    HBPreferences *preferences;
    BOOL kWriteITunesRingtonePlist;
}

@end

@implementation JFTHRingtoneImporter

#pragma mark - Init methods
- (instancetype)init {
    if (self = [super init]) {
        DDLogInfo(@"{\"Ringtone Import\":\"Init\"}");
        if (!preferences) {
            preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
            DDLogWarn(@"{\"Preferences\":\"Initializing preferences in importer.\"}");
        }
        [preferences registerBool:&kWriteITunesRingtonePlist default:NO forKey:@"kWriteITunesRingtonePlist"];
        
        DDLogVerbose(@"{\"Ringtone Import\":\"kWriteItunesPlist=%d\"}",kWriteITunesRingtonePlist);
        _ringtoneDataController = [[JFTHRingtoneDataController alloc] init];
        
        _ringtonesToImport = [[NSMutableDictionary alloc] init];
        _shouldImportRingtones = NO;

        self.importedCount = 0;
        
        if (kWriteITunesRingtonePlist)
            [_ringtoneDataController enableITunesRingtonePlistEditing];

        DDLogDebug(@"{\"Ringtone Import\":\"kWriteITunesRingtonePlist: %d\"}",kWriteITunesRingtonePlist);
    }
    return self;
}

#pragma mark - Search app method
- (void)getRingtoneFilesFromApp:(NSString *)bundleID {
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSString *appDirectory;
    
#ifdef JFTH_SIMULATOR
    if ([bundleID isEqualToString:@"fi.flodin.tonehelperdebugging"]) {
        appDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Downloads"];
        DDLogWarn(@"{\"Ringtone Import\":\"Debug folder loaded: %@\"}",appDirectory);
        
        
        
    } else {
#endif
        FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
        appDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        DDLogInfo(@"{\"Ringtone Import\":\"listing app folder for bundle: %@\"}",bundleID);
#ifdef JFTH_SIMULATOR
    }
#endif
    
    NSArray *appDirFiles = [localFileManager contentsOfDirectoryAtPath:appDirectory error:nil];
    
    DDLogInfo(@"{\"Ringtone Import\":\"Found these files: %@\"}", appDirFiles);
    NSMutableArray *m4rFiles = [[NSMutableArray alloc] init];
    
    if (!appDirFiles) // App unavailable or folder unavailable, not adding
        return;
    
    DDLogDebug(@"{\"Ringtone Import\":\"App folder available!\"}");

    if (!([appDirFiles count] > 0)) // Nothing to import for this app
        return;
    
    DDLogInfo(@"{\"Ringtone Import\":\"Found %lu files\"}", (unsigned long)[appDirFiles count]);

    for (NSString *file in appDirFiles) {
        if ([[file pathExtension] isEqualToString: @"m4r"]) {
            
            NSString *baseName = [JFTHRingtone createNameFromFile:file];
            // Check if ringtone already exists
            if ([_ringtoneDataController isImportedRingtoneWithName:baseName]) {
                continue;
            }
            
            // Does this name already exist in itunes plist?
            if ([_ringtoneDataController isITunesRingtoneWithName:baseName]) {
                DDLogWarn(@"{\"Ringtone Import\":\"Ringtone is already in itunes plist, name: %@\"}", baseName);
                continue;
            }
            if ([_ringtoneDataController isImportedRingtoneWithHash:[FileHash md5HashOfFileAtPath:[appDirectory stringByAppendingPathComponent:file]]]) {
                continue;
            }
            DDLogInfo(@"{\"Ringtone Import\":\"Adding ringtone to be imported: %@\"}", file);
            [m4rFiles addObject:file];
        }
    }
    if ([m4rFiles count] > 0) {
        // Add files to dict
        DDLogInfo(@"{\"Ringtone Import\":\"Found ringtones to import\"}");
        [_ringtonesToImport setObject:m4rFiles forKey:bundleID];
        _shouldImportRingtones = YES;
        
    } else {
        DDLogInfo(@"{\"Ringtone Import\":\"Found 0 ringtones to import\"}");
    }
}

#pragma mark - Should import methods
- (BOOL)shouldImportRingtones {
    DDLogDebug(@"{\"Ringtone Import\":\"shouldImport called with value: %d\"}",_shouldImportRingtones);
    return _shouldImportRingtones;
}

#pragma mark - Import
- (void)importNewRingtones {
    DDLogInfo(@"{\"Ringtone Import\":\"Import called\"}");

    // Loop through files
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    self.importedCount = 0;
    
    for (NSString *bundleID in _ringtonesToImport) // loop through all bundle ids, one app at a time
    { 
        FBApplicationInfo *appInfo = [LSApplicationProxy applicationProxyForIdentifier:bundleID];
        NSString *oldDirectory = [appInfo.dataContainerURL.path stringByAppendingPathComponent:@"Documents"];
        
        for (NSString *appDirFile in [_ringtonesToImport objectForKey:bundleID]) //loop through nsarray of m4r files
        {
            @autoreleasepool {

                // Create name
                NSString *baseName = [JFTHRingtone createNameFromFile:appDirFile];

                // Create new filename
                NSString *newFile = [[JFTHRingtone randomizedRingtoneParameter:JFTHRingtoneFileName] stringByAppendingString:@".m4r"];

                NSError *fileCopyError;
                if ([localFileManager copyItemAtPath:[
                    oldDirectory stringByAppendingPathComponent:appDirFile]
                                                         toPath:[RINGTONE_DIRECTORY stringByAppendingPathComponent:newFile]
                                                          error:&fileCopyError]) // Will import again at next run if moving. i dont want that.
                {
                    DDLogInfo(@"{\"Ringtone Import\":\"File copy success: %@\"}",appDirFile);
                    //Plist data
                    JFTHRingtone *newTone = [[JFTHRingtone alloc] initWithName:baseName
                                                                      fileName:newFile
                                                                   oldFileName:appDirFile
                                                                      bundleID:bundleID];
                    [_ringtoneDataController addRingtoneToPlist:newTone];
                    
                    self.importedCount++;

                } else {
                    DDLogError(@"{\"Ringtone Import\":\"File copy (%@) failed: %@\"}",appDirFile, fileCopyError);
                }
            }
        }
    }
}

@end
