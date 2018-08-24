#import "JFTHRingtoneListController.h"

BOOL kDebugLogging;

@implementation JFTHRingtoneListController

- (id)specifiers {
    if(_specifiers == nil) {
        // Loads specifiers from Name.plist from the bundle we're a part of.
        _specifiers = [self loadSpecifiersFromPlistName:@"Ringtones" target:self];
		NSDictionary *ringtones = [_toneData getImportedRingtones];

		for (NSString *fileName in ringtones) {
			NSDictionary *currentTone = [ringtones objectForKey:fileName];
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

		}
		
    }
    return _specifiers;
}

- (instancetype)init {
	//ALog(@"Initializing ringtone list");
	self = [super init];
    /*
    HBPreferences *preferences = [[HBPreferences alloc] initWithIdentifier:@"fi.flodin.tonehelper"];
    [preferences registerBool:&kDebugLogging default:NO forKey:@"kDebugLogging"];
    if (kDebugLogging) {
        LogglyLogger *logglyLogger = [[LogglyLogger alloc] init];
        [logglyLogger setLogFormatter:[[LogglyFormatter alloc] init]];
        logglyLogger.logglyKey = @"f962c4f9-899b-4d18-8f84-1da5d19e1184";
        
        // Set posting interval every 15 seconds, just for testing this out, but the default value of 600 seconds is better in apps
        // that normally don't access the network very often. When the user suspends the app, the logs will always be posted.
        logglyLogger.saveInterval = 15;
        
        [DDLog addLogger:logglyLogger];
    }*/
    
    //[DDLog addLogger:[DDASLLogger sharedInstance]];
    
	_toneData = [[JFTHRingtoneDataController alloc] init];

	return self;
}

-(void)removedSpecifier:(PSSpecifier*)specifier{
	[_toneData deleteRingtoneWithGUID:[specifier propertyForKey:@"key"]];
	//NSString *guid = [specifier ]
}

@end
