#import "UIAlertController+Window.m"
#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d JFDEBUG] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif
#define ALog(fmt, ...) NSLog((@"%s [Line %d JFDEBUG]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  preferredStyle:UIAlertControllerStyleAlert]; [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]]; [alert show]; }
#else
#   define ULog(...)
#endif