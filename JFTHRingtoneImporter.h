#import "ToneHelper.h"

typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};

@interface JFTHRingtoneImporter : NSObject {
    NSMutableDictionary *plist; //ringtones.plist
    NSMutableDictionary *ringtonesToImport;
    BOOL shouldImportRingtones;
}

+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;
- (void)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default

- (void)showSuccessHUDText:(NSString*)text;
- (void)showErrorHUDText:(NSString *)text;

- (BOOL)shouldImportRingtones;
- (void)setShouldImportRingtones:(BOOL)b;
- (void)saveRingtonesPlist;
- (void)importNewRingtones;


@end