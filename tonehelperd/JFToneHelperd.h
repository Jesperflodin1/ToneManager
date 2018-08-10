#import <Foundation/Foundation.h>
#import <FrontBoard/FBApplicationInfo.h>

@interface JFToneHelperd : NSObject {
    dispatch_source_t _source;
    NSArray* mFiles;
    NSString* mPath;
}

- (void)enable;
- (void)disable;
- (id)initWithURL:(NSString *)path;
- (void)directoryDidChange: (NSNotification*)n;
- (void)updateListWithNotification: (BOOL)withNotification;
//- (void)refreshPreferences;
@end

@interface LSApplicationProxy
/*MobileCoreServices*/
- (id)_initWithBundleUnit:(NSUInteger)arg1 applicationIdentifier:(NSString *)arg2;
+ (id)applicationProxyForIdentifier:(NSString *)arg1;
+ (id)applicationProxyForBundleURL:(NSURL *)arg1;
@end