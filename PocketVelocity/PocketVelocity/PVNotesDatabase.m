//
//  PVNotesDatabase.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "PVMutableListenableArray.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"

@interface PVNotesDatabase () <PVListening>

@end

@implementation PVNotesDatabase
{
  PVMutableListenableArray *_notes;
  dispatch_queue_t _queue;
}

- (instancetype)initWithDirectory:(NSURL *)directory
{
  self = [super init];
  if (self != nil) {
    _directory = [directory copy];
    _queue = dispatch_queue_create("com.brians-brain.pocketvelocity.notes-database", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
  }
  return self;
}

- (PVMutableListenableArray *)notes
{
  if (_notes != nil) {
    return _notes;
  }
  _notes = [[PVMutableListenableArray alloc] init];
  dispatch_async(_queue, ^{
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_directory
                                                               includingPropertiesForKeys:nil
                                                                                  options:0
                                                                                    error:&error];
    for (NSURL *fileURL in directoryContents) {
      [_notes addObject:[self _noteFromFileURL:fileURL]];
    }
  });
  [_notes addListener:self];
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

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(PVArrayChangeDescription *)changeDescription
{
  dispatch_async(_queue, ^{
    [changeDescription.indexesToAddFromUpdatedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
      PVNote *note = (PVNote *)changeDescription.updatedValues[idx];
      if (note.dirty) {
        NSURL *url = [self _fileURLFromNote:note];
        [note.note writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        PVMutableNote *updatedNote = [note mutableCopy];
        updatedNote.dirty = NO;
        _notes[idx] = updatedNote;
      }
    }];
  });
}

@end
