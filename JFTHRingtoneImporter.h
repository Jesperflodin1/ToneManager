#import "ToneHelper.h"
#include "FileHash.h"

typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};

@interface JFTHRingtoneImporter : NSObject {
    NSMutableDictionary *plist; //ringtones.plist
    NSMutableDictionary *ringtonesToImport;
    BOOL shouldImportRingtones;

    NSSet *md5ExistingRingtones;
}

+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;
- (NSString *)createNameFromFile:(NSString *)file;
- (void)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default
- (NSSet *)getMD5ForExistingRingtones;

- (void)showSuccessHUDText:(NSString*)text;
- (void)showErrorHUDText:(NSString *)text;
- (void)showTextHUD:(NSString *)text;

- (BOOL)shouldImportRingtones;
- (void)setShouldImportRingtones:(BOOL)b;
- (void)saveRingtonesPlist;
- (void)loadRingtonesPlist;
- (void)importNewRingtones;
- (void)addRingtoneToPlist:(NSString *)name file:(NSString *)fileName;


@end