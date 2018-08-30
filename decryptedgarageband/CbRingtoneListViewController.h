@interface CbRingToneListViewController: UITableViewController  
{
	NSArray *_ringToneNames;
	UIView *_emptyOverlay;
	UIView *_footer;
}

@property (readonly, non-atomic) NSArray * ringToneNames;
@property (readonly, non-atomic) UIView * footer;
@end
 -(void)switchEditMode:(id)arg1;
 -(id)ringToneNames;
 -(void)showEmptyOverlay:(BOOL)arg1;
 -(void).cxx_destruct;
 -(void)dealloc;
 -(double)tableView:(id)arg1 heightForFooterInSection:(long long)arg2;
 -(id)tableView:(id)arg1 viewForFooterInSection:(long long)arg2;
 -(BOOL)tableView:(id)arg1 shouldIndentWhileEditingRowAtIndexPath:(id)arg2;
 -(void)tableView:(id)arg1 willBeginEditingRowAtIndexPath:(id)arg2;
 -(void)tableView:(id)arg1 didEndEditingRowAtIndexPath:(id)arg2;
 -(long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
 -(id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
 -(void)tableView:(id)arg1 commitEditingStyle:(long long)arg2 forRowAtIndexPath:(id)arg3;
 -(unsigned long long)supportedInterfaceOrientations;
 -(void)didReceiveMemoryWarning;
 -(void)viewDidUnload;
 -(void)viewWillAppear:(BOOL)arg1;
 -(id)footer;
 -(void)cleanup;