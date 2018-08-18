#import "JFTHRingtoneListController.h"



@implementation JFTHRingtoneListController

- (id)specifiers {
    if(_specifiers == nil) {
        // Loads specifiers from Name.plist from the bundle we're a part of.
        _specifiers = [[self loadSpecifiersFromPlistName:@"Ringtones" target:self] retain];

		PSSpecifier* testSpecifier = [PSSpecifier preferenceSpecifierNamed:@"test"
									    target:self
									       set:NULL
									       get:@selector(readTestValue:)
									    detail:Nil
									      cell:PSListItemCell
									      edit:Nil];
		[_specifiers addObject:testSpecifier];
    }
    return _specifiers;
}

- (instancetype)init {
	if (self = [super init]) {
		_toneData =  [[JFTHRingtoneDataController alloc] init];
	}
	return self;
}

- (id)readTestValue:(PSSpecifier *)specifier {
	return @"test success!";
}
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PSTableCell *cell = (PSTableCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	//PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];

	cell.textLabel.text = @"Testing!!";
	cell.checked = YES;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	//PSSpecifier *specifier = _specifiers[[self indexForIndexPath:indexPath]];
	
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
 UITableViewRowAction *button = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Button 1" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
    {
        NSLog(@"Action to perform with Button 1");
    }];
    button.backgroundColor = [UIColor greenColor]; //arbitrary color
    UITableViewRowAction *button2 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"Button 2" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
                                        NSLog(@"Action to perform with Button2!");
                                    }];
    button2.backgroundColor = [UIColor blueColor]; //arbitrary color

    return @[button, button2]; //array with all the buttons you want. 1,2,3, etc...
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
// you need to implement this method too or nothing will work:

}
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES; //tableview must be editable or nothing will work...
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_toneData getImportedRingtones] count];
}*/

@end