#import <Foundation/Foundation.h>
#import <Cephei/HBPreferences.h>
#import "UIAlertController+Window.m"


#ifdef DEBUG
#   define DLog(args...) _JFLog(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
#   define DLog(...)
#endif
#define ALog(args...) _JFLog(@"DEBUG ", __FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  preferredStyle:UIAlertControllerStyleAlert]; [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]]; [alert show]; }
#else
#   define ULog(...)
#endif

BOOL kDebugLogging;
extern NSString *const HBPreferencesDidChangeNotification;


static void _JFLog(NSString *prefix, const char *file, int lineNumber, const char *funcName, NSString *format,...) {
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
    [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];
     if (!kDebugLogging) {
        return;
    }

    va_list ap;
    va_start (ap, format);
    format = [format stringByAppendingString:@"\n"];
    NSString *msg = [[NSString alloc] initWithFormat:[NSString stringWithFormat:@"%s [Line %d] %@",funcName,lineNumber,format] arguments:ap];   
    va_end (ap);

    //fprintf(stderr,"%s%50s:%3d - %s",[prefix UTF8String], funcName, lineNumber, [msg UTF8String]);
    //append(msg);
    //[msg release];

    // get path to Documents/somefile.txt
    NSString *documentsDirectory = @"/var/mobile/Library/ToneHelper";
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"logfile.txt"];
    // create if needed
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]){
        fprintf(stderr,"Creating file at %s",[path UTF8String]);
        [[NSData data] writeToFile:path atomically:YES];
    } 
    // append
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:path];
    [handle truncateFileAtOffset:[handle seekToEndOfFile]];
    [handle writeData:[msg dataUsingEncoding:NSUTF8StringEncoding]];
    [handle closeFile];
}
