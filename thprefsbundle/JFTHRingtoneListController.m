#import "JFTHRingtoneListController.h"





@implementation JFTHRingtoneListController

- (id)specifiers {
    if(_specifiers == nil) {
        // Loads specifiers from Name.plist from the bundle we're a part of.
        _specifiers = [self loadSpecifiersFromPlistName:@"Ringtones" target:self];

		NSDictionary *ringtones = [_toneData getImportedRingtones];

		for (NSString *fileName in ringtones) {
			DLog(@"Adding ringtone: %@",[ringtones objectForKey:fileName]);
			PSSpecifier* tone = [PSSpecifier preferenceSpecifierNamed:[[ringtones objectForKey:fileName] objectForKey:@"Name"]
									    target:self
									       set:NULL
									       get:NULL
									    detail:Nil
									      cell:PSListItemCell
									      edit:Nil];
			[tone setProperty:@YES forKey:@"enabled"];
			DLog(@"Adding specifier: %@", tone);
			//extern NSString* PSDeletionActionKey;
			// Set selector to call when removing specifier
			[tone setProperty:NSStringFromSelector(@selector(removedSpecifier:)) forKey:PSDeletionActionKey];
			[tone setProperty:@YES forKey:@"enabled"];
			[tone setProperty:@YES forKey:@"hasIcon"];
			[tone setProperty:[UIImage imageWithContentsOfFile:[[NSBundle bundleWithIdentifier:@"fi.flodin.thprefsbundle"] pathForResource:@"AudikoLite" ofType:@"png"]] forKey:@"iconImage"];
			//[tone setupIconImageWithPath:[[NSBundle bundleWithIdentifier:@"fi.flodin.thprefsbundle"] pathForResource:@"AudikoLite" ofType:@"png"]];
			[_specifiers addObject:tone];

		}
		
    }
    return _specifiers;
}

- (instancetype)init {
	DLog(@"Initializing ringtone list");
	self = [super init];
	_toneData = [[JFTHRingtoneDataController alloc] init];

	return self;
}

-(void)removedSpecifier:(PSSpecifier*)specifier{
	
	ULog(@"%@",[NSBundle bundleWithIdentifier:@"fi.flodin.thprefsbundle"]);
	ULog(@"%@",[[NSBundle bundleWithIdentifier:@"fi.flodin.thprefsbundle"] pathForResource:@"AudikoLite" ofType:@"png"]);
	DLog(@"removing specifier: %@",specifier);
}

@end