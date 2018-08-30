@interface CbLocalPublishers: NSObject <MAPublishSongExportDelegate,MAPublishSong> 
{
	<MAPublishSongDelegate> *_delegate;
	<MAPublishSongExport> *_exporter;
	unsigned long long _exportType;
	BOOL _stillBouncing;
	NSString *_songTitle;
	NSString *_pathToBouncedFile;
	UIImage *_coverArtwork;
	NSString *_songPath;
}

@property (non-atomic) unsigned long long exportType;
@property (retain, non-atomic) <MAPublishSongExport> * exporter;
@property (retain, non-atomic) NSString * songTitle;
@property (retain, non-atomic) NSString * pathToBouncedFile;
@property (retain, non-atomic) UIImage * coverArtwork;
@property (retain, non-atomic) NSString * songPath;
@property (non-atomic) BOOL stillBouncing;
@property (readonly) unsigned long long hash;
@property (readonly) class superclass;
@property (readonly, copy) NSString * description;
@property (readonly, copy) NSString * debugDescription;
@property (non-atomic) <MAPublishSongDelegate> * publishDelegate;
@end
 -(unsigned long long)exportType;
 -(void)setExportType:(unsigned long long)arg1;
 -(void)songExportDidFinish:(id)arg1;
 -(void)songExportDidFail:(id)arg1 error:(id)arg2;
 -(void)setExporter:(id)arg1;
 -(void)songExportDidCancel:(id)arg1;
 -(id)publishDelegate;
 -(void)startPublish;
 -(BOOL)stillBouncing;
 -(id)pathToBouncedFile;
 -(void)setStillBouncing:(BOOL)arg1;
 -(id)songTitle;
 -(void)setPathToBouncedFile:(id)arg1;
 -(void)setCoverArtwork:(id)arg1;
 -(void)cancelPublish;
 -(void)setPublishDelegate:(id)arg1;
 -(void)songExport:(id)arg1 progress:(double)arg2;
 -(void)setSongTitle:(id)arg1;
 -(id)coverArtwork;
 -(id)exporter;
 -(void).cxx_destruct;
 -(void)show;
 -(id)songPath;
 -(void)setSongPath:(id)arg1;
 -(id)progressString;