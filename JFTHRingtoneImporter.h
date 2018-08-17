#import "ToneHelper.h"
#import "JFTHRingtoneDataController.h"
#include "FileHash.h"

@interface JFTHRingtoneImporter : NSObject {
    
    NSMutableDictionary *ringtonesToImport;
    BOOL shouldImportRingtones;

    //NSSet *md5ExistingRingtones;

    JGProgressHUD *_textHUD;
    JGProgressHUD *_statusHUD;
    
    JFTHRingtoneDataController *_ringtoneData;
}

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