/*
* This header is generated by classdump-dyld 1.0
* on Wednesday, August 22, 2018 at 12:28:31 AM Central European Summer Time
* Operating System: Version 11.3.1 (Build 15E302)
* Image Source: /System/Library/PrivateFrameworks/ToneLibrary.framework/ToneLibrary
* classdump-dyld is licensed under GPLv3, Copyright © 2013-2016 by Elias Limneos.
*/


@protocol OS_dispatch_queue;
@class NSObject, NSString, NSMutableDictionary, AWAttentionAwarenessClient;

@interface TLAttentionAwarenessObserver : NSObject {

	NSObject*<OS_dispatch_queue> _accessQueue;
	NSString* _accessQueueLabel;
	NSMutableDictionary* _pollingForAttentionEventHandlers;
	BOOL _isFullyInitialized;
	BOOL _isPollingForAttention;
	AWAttentionAwarenessClient* _attentionAwarenessClient;
	NSObject*<OS_dispatch_queue> _attentionAwarenessClientQueue;

}
+(id)sharedAttentionAwarenessObserver;
+(BOOL)supportsAttenuatingTonesForAttentionDetected;
-(id)init;
-(void)dealloc;
-(void)_assertRunningOnAccessQueue;
-(void)_assertNotRunningOnAccessQueue;
-(void)_didCompleteInitialization;
-(void)_endPollingForAttention;
-(void)_invokePollingForAttentionEventHandlers:(id)arg1 eventType:(long long)arg2 ;
-(void)_beginPollingForAttention;
-(void)_didReceiveAttentionPollingEventOfType:(unsigned long long)arg1 attentionEvent:(id)arg2 ;
-(id)pollForAttentionWithEventHandler:(/*^block*/id)arg1 ;
-(void)cancelPollForAttentionWithToken:(id)arg1 ;
@end
