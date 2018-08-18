#import "JFTHRingtoneListController.h"
#import "../UIAlertController+Window.m"




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
	
	
	
	DLog(@"removing specifier: %@",specifier);
}

@end