//
//  PVNotesDatabase.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "VOArrayFilterer.h"
#import "VOBlockListener.h"
#import "VOListenersCollection.h"
#import "VOMutableChangeDescribingArray.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"

@interface PVNotesDatabase ()

@end

@implementation PVNotesDatabase
{
  dispatch_queue_t _queue;
  VOListenersCollection *_listeners;
}

- (instancetype)initWithDirectory:(NSURL *)directory
{
  self = [super init];
  if (self != nil) {
    _directory = [directory copy];
    _queue = dispatch_queue_create("com.brians-brain.pocketvelocity.notes-database", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    _listeners = [[VOListenersCollection alloc] initWithCurrentValue:nil];
    _notes = [[VOChangeDescribingArray alloc] init];
  }
  return self;
}

- (void)updateNotesWithBlock:(PVNotesDatabaseUpdatingBlock)block
{
  dispatch_async(_queue, ^{
    VOChangeDescribingArray *results = block(_notes);
    _notes = [results copy];
    VOArrayChangeDescription *changeDescription = _notes.changeDescription;
    NSUInteger totalChangesCount = changeDescription.indexesToAddFromUpdatedValues.count + changeDescription.indexesToRemoveFromOldValues.count;
    if (totalChangesCount > 0) {
      [_listeners listenableObject:self didUpdateToValue:_notes];
    }
  });
}

- (void)loadNotesFromDisk
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *notesFromDisk = [self _notesFromDisk];
    [self updateNotesWithBlock:^VOChangeDescribingArray *(VOChangeDescribingArray *currentNotes) {
      VOMutableChangeDescribingArray *mutableNotes = [currentNotes mutableCopy];
      for (PVNote *note in notesFromDisk) {
        [mutableNotes addObject:note];
      }
      return mutableNotes;
    }];
  });
}

- (void)removeNoteWithTitle:(NSString *)noteTitle
{
  [self updateNotesWithBlock:^VOChangeDescribingArray *(VOChangeDescribingArray *currentNotes) {
    NSUInteger idx;
    for (idx = 0; idx < currentNotes.count; idx++) {
      PVNote *note = currentNotes[idx];
      if ([note.title isEqualToString:noteTitle]) {
        break;
      }
    }
    if (idx < currentNotes.count) {
      VOMutableChangeDescribingArray *mutableCopy = [currentNotes mutableCopy];
      [mutableCopy removeObjectAtIndex:idx];
      return mutableCopy;
    }
    return currentNotes;
  }];
}

- (NSArray *)_notesFromDisk
{
  NSMutableArray *notesFromDisk = [[NSMutableArray alloc] init];
  NSError *error;
  NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_directory
                                                             includingPropertiesForKeys:nil
                                                                                options:0
                                                                                  error:&error];
  for (NSURL *fileURL in directoryContents) {
    [notesFromDisk addObject:[self _noteFromFileURL:fileURL]];
  }
  return notesFromDisk;
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

- (VOBlockListener *)autoSaveListener
{
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  return [[[[VOPipeline alloc] initWithName:@"com.brians-brain.pocket-velocity.autosave" source:self] pipelineWithArrayFilteringBlock:^id(PVNote *note) {
    if (note.dirty) {
      return note;
    }
    return nil;
  }] blockListenerOnQueue:queue block:^(VOChangeDescribingArray *notes) {
    if (!notes.count) {
      return;
    }
    for (PVNote *note in notes) {
      NSURL *url = [self _fileURLFromNote:note];
      [note.note writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    [self updateNotesWithBlock:^VOChangeDescribingArray *(VOChangeDescribingArray *currentNotes) {
      VOMutableChangeDescribingArray *mutableNotes = [currentNotes mutableCopy];
      for (PVNote *savedNote in notes) {
        for (NSUInteger idx = 0; idx < mutableNotes.count; idx++) {
          PVNote *existingNote = mutableNotes[idx];
          if ([savedNote.title isEqualToString:existingNote.title]) {
            if ([savedNote.note isEqualToString:existingNote.note]) {
              PVMutableNote *mutableNote = [existingNote mutableCopy];
              mutableNote.dirty = NO;
              mutableNotes[idx] = mutableNote;
            }
          }
        }
      }
      return mutableNotes;
    }];
  }];
}

- (void)updateNote:(PVNote *)noteToUpdate
{
  [self updateNotesWithBlock:^VOChangeDescribingArray *(VOChangeDescribingArray *currentNotes) {
    VOMutableChangeDescribingArray *mutableCopy = [currentNotes mutableCopy];
    NSUInteger idx;
    for (idx = 0; idx < mutableCopy.count; idx++) {
      PVNote *note = mutableCopy[idx];
      if ([note.title isEqualToString:noteToUpdate.title]) {
        mutableCopy[idx] = noteToUpdate;
        break;
      }
    }
    if (idx == mutableCopy.count) {
      [mutableCopy addObject:noteToUpdate];
    }
    return mutableCopy;
  }];
}

#pragma mark - PVListenable

- (id)addListener:(id<VOPipelineSink>)listener
{
  [_listeners addListener:listener];
  return _notes;
}

- (void)removeListener:(id<VOPipelineSink>)listener
{
  [_listeners removeListener:listener];
}

@end
