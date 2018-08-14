#ifdef DEBUG
#define NSLog(args...) _Log(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else 
#define NSLog(...) (void)0
#endif

#import <Foundation/Foundation.h>
@interface Log : NSObject
void _Log(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...);
@end