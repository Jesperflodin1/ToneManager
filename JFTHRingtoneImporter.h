#import <Foundation/Foundation.h>

@class JFTHRingtoneDataController;

@interface JFTHRingtoneImporter : NSObject {
    
}

@property (nonatomic) int importedCount;

- (NSString *)createNameFromFile:(NSString *)file;
- (void)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default

- (BOOL)shouldImportRingtones;

- (void)importNewRingtones;



@end
