//
//  PVNotesDatabase.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "PVListenersCollection.h"
#import "VOMutableChangeDescribingArray.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"

@interface PVNotesDatabase ()

@end

@implementation PVNotesDatabase
{
  VOChangeDescribingArray *_notes;
  dispatch_queue_t _queue;
  PVListenersCollection *_listeners;
}

- (instancetype)initWithDirectory:(NSURL *)directory
{
  self = [super init];
  if (self != nil) {
    _directory = [directory copy];
    _queue = dispatch_queue_create("com.brians-brain.pocketvelocity.notes-database", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    _listeners = [[PVListenersCollection alloc] init];
  }
  return self;
}

- (void)updateNotesWithBlock:(PVNotesDatabaseUpdatingBlock)block
{
  dispatch_async(_queue, ^{
    VOChangeDescribingArray *results = block(_notes);
    _notes = [results copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [_listeners listenableObject:self didChangeWithDescription:_notes];
    });
  });
}

- (VOChangeDescribingArray *)notes
{
  if (_notes != nil) {
    return _notes;
  }
  NSMutableArray *notesFromDisk = [[NSMutableArray alloc] init];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_directory
                                                               includingPropertiesForKeys:nil
                                                                                  options:0
                                                                                    error:&error];
    for (NSURL *fileURL in directoryContents) {
      [notesFromDisk addObject:[self _noteFromFileURL:fileURL]];
    }
    if (notesFromDisk.count > 0) {
      [self updateNotesWithBlock:^VOChangeDescribingArray *(VOChangeDescribingArray *currentNotes) {
        VOMutableChangeDescribingArray *mutableNotes = [currentNotes mutableCopy];
        for (PVNote *note in notesFromDisk) {
          [mutableNotes addObject:note];
        }
        return mutableNotes;
      }];
    }
  });
  return _notes;
}

- (PVNote *)_noteFromFileURL:(NSURL *)fileURL
{
  NSError *error;
  NSString *noteContents = [NSString stringWithContentsOfURL:fileURL encoding:NSUTF8StringEncoding error:&error];
  if (!noteContents) {
    @throw [NSException exceptionWithName:NSDestinationInvalidException reason:@"Could not read file" userInfo:@{@"error": error}];
  }
  NSArray *pathComponents = [fileURL pathComponents];
  NSString *lastComponent = [pathComponents lastObject];
  lastComponent = [[lastComponent stringByRemovingPercentEncoding] stringByDeletingPathExtension];
  NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:fileURL.path error:&error];
  return [[PVNote alloc] initWithTitle:lastComponent
                                  note:noteContents
                                  tags:nil
                             dateAdded:attributes[NSFileCreationDate]
                          dateModified:attributes[NSFileModificationDate]
                                 dirty:NO];
}

- (NSURL *)_fileURLFromNote:(PVNote *)note
{
  NSString *filename = [note.title stringByAppendingPathExtension:@"txt"];
  NSURL *url = [[NSURL alloc] initFileURLWithFileSystemRepresentation:[filename UTF8String] isDirectory:NO relativeToURL:_directory];
  return url;
}

#pragma mark - PVListenable

- (void)addListener:(id<PVListening>)listener
{
  [_listeners addListener:listener];
}

- (void)removeListener:(id<PVListening>)listener
{
  [_listeners removeListener:listener];
}

@end
