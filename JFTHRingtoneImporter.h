#import "JFTHHeaders.h"
#import "JFTHRingtoneDataController.h"

//For md5 calculations
#include "FileHash.h"

@class JFTHRingtoneDataController;

@interface JFTHRingtoneImporter : NSObject {
    
    NSMutableDictionary *ringtonesToImport;
    BOOL shouldImportRingtones;

    //NSSet *md5ExistingRingtones;

    JGProgressHUD *_textHUD;
    JGProgressHUD *_statusHUD;
    
    JFTHRingtoneDataController *_ringtoneData;
}

@property int importedCount;

- (NSString *)createNameFromFile:(NSString *)file;
- (void)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default
//- (NSSet *)getMD5ForExistingRingtones;

- (void)showSuccessHUDText:(NSString*)text;
- (void)showErrorHUDText:(NSString *)text;
- (void)showTextHUD:(NSString *)text;

- (BOOL)shouldImportRingtones;
- (void)setShouldImportRingtones:(BOOL)b;


- (void)importNewRingtones;



@end
