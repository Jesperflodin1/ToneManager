#import "JFTHPrefHeaders.h"

@class TSIncludeInstruction;

NS_ASSUME_NONNULL_BEGIN


@interface JFTHRootListController : HBRootListController

+ (nullable NSString *)hb_supportEmailAddress;
+ (nullable NSArray <TSIncludeInstruction *> *)hb_supportInstructions;
- (void)hb_sendSupportEmail;

- (void)hb_openURL:(PSSpecifier *)specifier;

@end

NS_ASSUME_NONNULL_END


