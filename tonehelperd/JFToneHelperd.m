#import "JFToneHelperd.h"

@implementation JFToneHelperd

- (id)initWithURL:(NSString *)path
{
    self = [self init];
    if (self)
    {
        mPath = path;
        //_keepMonitoringFile = NO;
        [self enable];
    }
    return self;
}

- (void)enable {
    if (_source != NULL) return;
    if (!mPath) return;

    // Add an observer
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(directoryDidChange:) name:@"FilesChanged" object:self];

    // Event only file descriptor
    int fildes = open(mPath.UTF8String, O_RDONLY);

    dispatch_queue_t queue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);

    dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fildes, DISPATCH_VNODE_DELETE | DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND | DISPATCH_VNODE_RENAME | DISPATCH_VNODE_REVOKE, queue);

    dispatch_source_set_event_handler(source, ^{
        NSLog(@"DEBUG: Sending event notification");
        [self updateListWithNotification: YES];
    });

    dispatch_source_set_cancel_handler(source, ^{
        close((int)dispatch_source_get_handle(source));
    });

    _source = source;

    dispatch_resume(source); // Start monitoring

    dispatch_async(queue, ^{
        [self updateListWithNotification: NO];
    });
}
- (void)disable {
    if (_source)
	{
		// Stop the source from submitting further blocks (and close the underlying FD)
		dispatch_source_cancel(_source);
		
		// Release the source
		//dispatch_release(_source);
		_source = NULL;
	}
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FilesChanged" object:self];
    dispatch_source_cancel(_source); // Stop monitoring
    [super dealloc];
}

- (void)updateListWithNotification: (BOOL)withNotification
{
    // Our manipulation of state here is OK because we know this only ever gets called on a serial queue
    mFiles = mFiles ?: [NSArray array];

    NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath: mPath error: nil] ?: [NSArray array];

    if (withNotification)
    {
        NSSet* oldFiles = [NSSet setWithArray: mFiles];
        NSSet* newFiles = [NSSet setWithArray: contents];

        NSMutableSet* addedFiles = [newFiles mutableCopy]; [addedFiles minusSet: oldFiles];
        NSMutableSet* removedFiles = [oldFiles mutableCopy]; [removedFiles minusSet: newFiles];
        NSDictionary* ui = @{ @"FilesRemoved" : removedFiles, @"FilesAdded" : addedFiles };
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName: @"FilesChanged" object: self userInfo: ui];
        });
    }

    mFiles = contents;
}

- (void)directoryDidChange: (NSNotification*)n
{
    NSLog(@"Directory %@ changed.\nFiles removed: %@\nFiles added: %@", mPath, n.userInfo[@"FilesRemoved"], n.userInfo[@"FilesAdded"]);
}

@end