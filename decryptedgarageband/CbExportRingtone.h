@interface CbExportRingtone: CbLocalPublishers <CNContactPickerDelegate> 
{
	<ToneManagerInterface> *_toneManager;
	CNMutableContact *_personToAssignTo;
	NSString *_toneName;
}

@property (readonly, non-atomic) <ToneManagerInterface> * toneManager;
@property (copy, non-atomic) NSString * toneName;
@property (readonly) unsigned long long hash;
@property (readonly) class superclass;
@property (readonly, copy) NSString * description;
@property (readonly, copy) NSString * debugDescription;
@end
 +(BOOL)checkLengthOfSongAtPath:(id)arg1;
 +(id)localRingtonesInfoPath;
 +(class)toneManagerClass;
 +(id)localRingtoneInfo;
 +(void)removeRingtoneWithName:(id)arg1;
 +(BOOL)canExport;
 -(void)songExportDidFinish:(id)arg1;
 -(void)songExportDidFail:(id)arg1 error:(id)arg2;
 -(void)showExportFinishedAlert;
 -(BOOL)shouldShowMoreOptionsAlert;
 -(void)assignCurrentToneToContact;
 -(void)alertActionHandler:(int)arg1;
 -(id)toneName;
 -(void)setToneName:(id)arg1;
 -(void).cxx_destruct;
 -(void)show;
 -(void)showMoreOptions;
 -(void)contactPickerDidCancel:(id)arg1;
 -(void)contactPicker:(id)arg1 didSelectContact:(id)arg2;
 -(id)progressString;
 -(id)toneManager;