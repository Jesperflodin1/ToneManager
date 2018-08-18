#import "JFTHRingtoneListController.h"
#import "../Log.h"



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
									       get:@selector(readTestValue:)
									    detail:Nil
									      cell:PSListItemCell
									      edit:Nil];
			[tone setProperty:@YES forKey:@"enabled"];
			DLog(@"Adding specifier: %@", tone);
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

- (id)readTestValue:(PSSpecifier *)specifier {
	DLog(@"specifier: %@",specifier);
	return @"test success!";
}

@end