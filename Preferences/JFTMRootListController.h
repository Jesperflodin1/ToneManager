#import "JFTMPrefHeaders.h"
#import <CepheiPrefs/HBRootListController.h>
#import <Cephei/HBRespringController.h>
#import <CepheiPrefs/HBTwitterCell.h>
#import <CepheiPrefs/HBPackageNameHeaderCell.h>
#import <CepheiPrefs/HBLinkTableCell.h>
#include <version.h>


@interface JFTMRootListController : HBRootListController

- (void)hb_sendSupportEmail;

- (void)hb_openURL:(PSSpecifier *)specifier;

@end


