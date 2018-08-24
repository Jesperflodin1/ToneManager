#import "JFTHHeaders.h"
#import "JFTHRingtoneDataController.h"

//For md5 calculations
#include "FileHash.h"

@class JFTHRingtoneDataController;

@interface JFTHRingtoneImporter : NSObject {
    
    NSMutableDictionary *ringtonesToImport;
    BOOL shouldImportRingtones;
    
    JFTHRingtoneDataController *_ringtoneData;
}

@property (nonatomic) int importedCount;

- (NSString *)createNameFromFile:(NSString *)file;
- (void)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default

- (BOOL)shouldImportRingtones;
- (void)setShouldImportRingtones:(BOOL)b;


- (void)importNewRingtones;



@end
