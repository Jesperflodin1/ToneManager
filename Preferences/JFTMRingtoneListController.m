#import "JFTMRingtoneListController.h"

//extern NSString *const HBPreferencesDidChangeNotification;
//HBPreferences *preferences;

//NSDictionary *_ringtonesImported;

@implementation JFTMRingtoneListController

- (id)specifiers {
    if(_specifiers == nil) {
        // Loads specifiers from Name.plist from the bundle we're a part of.
        _specifiers = [self loadSpecifiersFromPlistName:@"Ringtones" target:self];
        /*NSLog(@"Got ringtones: %@",_ringtonesImported);
		for (NSString *fileName in _ringtonesImported) {
            
			NSDictionary *currentTone = [_ringtonesImported objectForKey:fileName];
            NSLog(@"Loaded tone: %@",currentTone);
			//ALog(@"Adding ringtone: %@",[ringtones objectForKey:fileName]);
            
			PSSpecifier* tone = [PSSpecifier preferenceSpecifierNamed:[currentTone objectForKey:@"Name"]
									    target:self
									       set:NULL
									       get:NULL
									    detail:Nil
									      cell:PSListItemCell
									      edit:Nil];
			[tone setProperty:@YES forKey:@"enabled"];
            
			//DLog(@"Adding specifier: %@", tone);
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

		}*/
		
    }
    return _specifiers;
}

- (instancetype)init {
	self = [super init];
    
    //preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
    //[preferences registerObject:&_ringtonesImported default:[[NSDictionary alloc] init] forKey:@"Ringtones"];

	return self;
}

-(void)removedSpecifier:(PSSpecifier*)specifier{
    
    if (NSClassFromString(@"TLToneManager")) {
        NSLog(@"TLToneManager loaded JFDEBUG");
    } else {
        NSLog(@"TLToneManager NOT loaded JFDEBUG");
    }
    
	//[_toneData deleteRingtoneWithGUID:[specifier propertyForKey:@"key"]];
}

@end
