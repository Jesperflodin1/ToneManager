/*
* This header is generated by classdump-dyld 1.0
* on Wednesday, August 22, 2018 at 12:28:31 AM Central European Summer Time
* Operating System: Version 11.3.1 (Build 15E302)
* Image Source: /System/Library/PrivateFrameworks/ToneKit.framework/ToneKit
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/

#import <ToneKit/TKPickerSelectableItem.h>
#import <libobjc.A.dylib/TKPickerContainerItem.h>

@class TKTonePickerController, TKTonePickerSectionItem, NSString;

@interface TKTonePickerItem : TKPickerSelectableItem <TKPickerContainerItem> {

	BOOL _needsRoomForCheckmark;
	BOOL _needsActivityIndicator;
	BOOL _needsDownloadProgress;
	float _downloadProgress;
	unsigned long long _itemKind;
	TKTonePickerController* __parentTonePickerController;
	long long _numberOfChildren;

}

@property (assign,setter=_setParentTonePickerController:,nonatomic,__weak) TKTonePickerController * _parentTonePickerController;              //@synthesize _parentTonePickerController=__parentTonePickerController - In the implementation block
@property (assign,setter=_setNumberOfChildren:,nonatomic) long long numberOfChildren;                                                         //@synthesize numberOfChildren=_numberOfChildren - In the implementation block
@property (assign,setter=_setItemKind:,nonatomic) unsigned long long itemKind;                                                                //@synthesize itemKind=_itemKind - In the implementation block
@property (assign,setter=_setNeedsRoomForCheckmark:,nonatomic) BOOL needsRoomForCheckmark;                                                    //@synthesize needsRoomForCheckmark=_needsRoomForCheckmark - In the implementation block
@property (assign,setter=_setNeedsActivityIndicator:,nonatomic) BOOL needsActivityIndicator;                                                  //@synthesize needsActivityIndicator=_needsActivityIndicator - In the implementation block
@property (assign,setter=_setNeedsDownloadProgress:,nonatomic) BOOL needsDownloadProgress;                                                    //@synthesize needsDownloadProgress=_needsDownloadProgress - In the implementation block
@property (assign,setter=_setDownloadProgress:,nonatomic) float downloadProgress;                                                             //@synthesize downloadProgress=_downloadProgress - In the implementation block
@property (nonatomic,readonly) TKTonePickerSectionItem * parentSectionItem; 
@property (readonly) unsigned long long hash; 
@property (readonly) Class superclass; 
@property (copy,readonly) NSString * description; 
@property (copy,readonly) NSString * debugDescription; 
-(void)_setItemKind:(unsigned long long)arg1 ;
-(long long)numberOfChildren;
-(float)downloadProgress;
-(unsigned long long)itemKind;
-(void)_setNumberOfChildren:(long long)arg1 ;
-(void)_setParentTonePickerController:(id)arg1 ;
-(void)_setNeedsRoomForCheckmark:(BOOL)arg1 ;
-(void)_setNeedsActivityIndicator:(BOOL)arg1 ;
-(void)_setNeedsDownloadProgress:(BOOL)arg1 ;
-(void)_setDownloadProgress:(float)arg1 ;
-(id)childItemAtIndex:(long long)arg1 ;
-(BOOL)needsActivityIndicator;
-(BOOL)needsDownloadProgress;
-(BOOL)needsRoomForCheckmark;
-(TKTonePickerController *)_parentTonePickerController;
-(void)_appendDescriptionOfAttributesToString:(id)arg1 ;
-(TKTonePickerSectionItem *)parentSectionItem;
@end
