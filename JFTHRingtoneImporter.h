#import "ToneHelper.h"

typedef NS_ENUM(NSInteger, JFTHRingtoneParameterType) {
    JFTHRingtoneFileName,
    JFTHRingtoneGUID,
    JFTHRingtonePID
};

@interface JFTHRingtoneImporter : NSObject {
    int progress;
}

@property (nonatomic) JGProgressHUD* progressHUD;

+ (NSString *)randomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;
+ (NSArray *)getRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)folder;
+ (NSArray *)getRingtoneFilesFromApp:(NSString *)bundleID; //Uses "Documents" as folder, default
- (void)initHUD;
- (void)showProgressHUD;
- (void)showSuccessHUD;
- (void)setProgress:(int)p;


@end