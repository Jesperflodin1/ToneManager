//
// Created by Mats Melke on 2014-02-20.
//

#import <Foundation/Foundation.h>
#import "LogglyFormatter.h"

@interface LogglyFields : NSObject <LogglyFieldsDelegate>
//@property (strong, nonatomic) NSString *appversion;
//@property (strong, nonatomic) NSString *userid;
//@property (strong, nonatomic) NSString *sessionid;

- (void)setUserid:(NSString *)userid;
- (void)setSessionid:(NSString *)sessionid;
- (void)setAppversion:(NSString *)appversion;
@end
