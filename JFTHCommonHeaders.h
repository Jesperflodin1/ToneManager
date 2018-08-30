
#import <Foundation/Foundation.h>
#import <Cephei/HBPreferences.h>

#import "CocoaLumberjack/CocoaLumberjack.h"
#import "LogglyLogger/LogglyLogger.h"
#import "LogglyLogger/LogglyFormatter.h"
#import "LogglyLogger/LogglyFields.h"

#ifdef DEBUG
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#else
static const DDLogLevel ddLogLevel = DDLogLevelVerbose;
#endif

static HBPreferences *preferences;

static BOOL kWriteITunesRingtonePlist;
