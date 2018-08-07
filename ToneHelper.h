#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// https://github.com/Mantle/Mantle/blob/master/Mantle/MTLModel.h
@interface MTLModel : NSObject
@end

@interface AUAudikoRingtone : MTLModel

@end


@interface AURingtoneControlsHeaderView : UIView

@property (assign) UIButton *downloadButton; 

@end


@interface AUSelectedRingtoneViewController : UIViewController

@property (assign) AUAudikoRingtone *currentRingtone;
@property (assign) AURingtoneControlsHeaderView *controlsHeaderView;

@end

