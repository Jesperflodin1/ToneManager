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

+ (NSString *)JFTH_RandomizedRingtoneParameter:(JFTHRingtoneParameterType)Type;
+ (NSArray *)getRingtoneFilesFromApp:(NSString *)bundleID withSubfolder:(NSString *)folder;
- (void)initHUD;
- (void)showProgressHUD;
- (void)showSuccessHUD;
- (void)setProgress:(int)p;


@end