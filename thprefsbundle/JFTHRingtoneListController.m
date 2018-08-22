#import "JFTHRingtoneListController.h"

@implementation JFTHRingtoneListController

- (id)specifiers {
    if(_specifiers == nil) {
        // Loads specifiers from Name.plist from the bundle we're a part of.
        _specifiers = [self loadSpecifiersFromPlistName:@"Ringtones" target:self];
		NSDictionary *ringtones = [_toneData getImportedRingtones];

		for (NSString *fileName in ringtones) {
			NSDictionary *currentTone = [ringtones objectForKey:fileName];
			DLog(@"Adding ringtone: %@",[ringtones objectForKey:fileName]);
			PSSpecifier* tone = [PSSpecifier preferenceSpecifierNamed:[currentTone objectForKey:@"Name"]
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
			//[tone setProperty:@YES forKey:@"enabled"];

			//Set GUID so we can identify the ringtone if user chooses to delete it
			[tone setProperty:[currentTone objectForKey:@"GUID"] forKey:@"key"];

			NSBundle *prefBundle = [NSBundle bundleWithIdentifier:@"fi.flodin.thprefsbundle"];
			NSString *importedFrom = [currentTone objectForKey:@"ImportedFromBundleID"];
			if (importedFrom) {
				[tone setProperty:@YES forKey:@"hasIcon"];
				if ([importedFrom isEqualToString:@"com.908.AudikoFree"])
					[tone setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"AudikoLite" ofType:@"png"]] forKey:@"iconImage"];
				else if ([importedFrom isEqualToString:@"com.908.Audiko"])
					[tone setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"AudikoPro" ofType:@"png"]] forKey:@"iconImage"];
				else if ([importedFrom isEqualToString:@"com.zedge.Zedge"])
					[tone setProperty:[UIImage imageWithContentsOfFile:[prefBundle pathForResource:@"Zedge" ofType:@"png"]] forKey:@"iconImage"];

			}
			
			[_specifiers addObject:tone];

		}
		
    }
    return _specifiers;
}

- (instancetype)init {
	ALog(@"Initializing ringtone list");
	self = [super init];
	_toneData = [[JFTHRingtoneDataController alloc] init];

	return self;
}

-(void)removedSpecifier:(PSSpecifier*)specifier{
	[_toneData deleteRingtoneWithGUID:[specifier propertyForKey:@"key"]];
	//NSString *guid = [specifier ]
}

@end