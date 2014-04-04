//
//  PVNotesDatabase.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "VOArrayFilterer.h"
#import "VOAsyncPipelineStage.h"
#import "VOBlockListener.h"
#import "VOChangeDescribingDictionary.h"
#import "VOCoalescingPipelineStage.h"
#import "VODictionaryChangeDescription.h"
#import "VODictionaryFilterer.h"
#import "VOPipelineStage.h"
#import "VOMutableChangeDescribingArray.h"
#import "VOMutableChangeDescribingDictionary.h"
#import "PVNote.h"
#import "PVNotesDatabase.h"

static NSString * const kNoteExtension = @"txt";

@interface PVNotesDatabase ()

@end

@implementation PVNotesDatabase
{
  dispatch_queue_t _queue;
  VOPipelineStage *_listeners;
}

- (instancetype)initWithDirectory:(NSURL *)directory
{
  self = [super init];
  if (self != nil) {
    _directory = [directory copy];
    _queue = dispatch_queue_create("com.brians-brain.pocketvelocity.notes-database", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_queue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    _listeners = [[VOPipelineStage alloc] init];
    _notes = [[VOChangeDescribingDictionary alloc] init];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ notes = %@", [super description], _notes];
}

- (NSString *)pipelineDescription
{
  return [self description];
}

- (void)updateNotesWithBlock:(PVNotesDatabaseUpdatingBlock)block
{
  do { } while (NO);
  dispatch_async(_queue, ^{
    VOChangeDescribingDictionary *results = block(_notes);
    _notes = [results copy];
    VODictionaryChangeDescription *changeDescription = _notes.changeDescription;
    NSUInteger totalChangesCount = changeDescription.removedKeys.count + changeDescription.insertedOrUpdatedKeys.count;
    if (totalChangesCount > 0) {
      [_listeners pipelineSource:self didUpdateToValue:_notes];
    }
  });
}

- (void)removeNoteWithTitle:(NSString *)noteTitle
{
  [self updateNotesWithBlock:^VOChangeDescribingDictionary *(VOChangeDescribingDictionary *currentNotes) {
    PVNote *note = currentNotes[noteTitle];
    if (note == nil) {
      return currentNotes;
    }
    VOMutableChangeDescribingDictionary *mutableNotes = [currentNotes mutableCopy];
    [mutableNotes removeObjectForKey:noteTitle];
    NSURL *fileURL = [self _fileURLFromNote:note];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      [[NSFileManager defaultManager] removeItemAtURL:fileURL error:NULL];
    });
    return [mutableNotes copy];
  }];
}

- (id)currentValue
{
  return _notes;
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
    NSString *pathExtension = [fileURL pathExtension];
    if ([pathExtension isEqualToString:kNoteExtension]) {
      [notesFromDisk addObject:[self _noteFromFileURL:fileURL]];
    }
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
  NSString *filename = [note.title stringByAppendingPathExtension:kNoteExtension];
  NSURL *url = [[NSURL alloc] initFileURLWithFileSystemRepresentation:[filename UTF8String] isDirectory:NO relativeToURL:_directory];
  return url;
}

- (VOBlockListener *)autoSaveListener
{
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  return [[[[[VOAsyncPipelineStage alloc] initWithSource:self queueName:@"com.brians-brain.pocket-velocity.autosave"] pipelineByFilteringDictionaryWithBlock:^BOOL(NSString *noteTitle, PVNote *note) {
    if (note.dirty) {
      return YES;
    }
    return NO;
  }] pipelineStageCoalescedWithTimeInterval:10]
      blockListenerOnQueue:queue block:^(VOChangeDescribingDictionary *notes) {
        NSDictionary *notesDictionary = notes.dictionary;
        if (!notesDictionary.count) {
          return;
        }
        for (PVNote *note in notesDictionary.allValues) {
          NSURL *url = [self _fileURLFromNote:note];
          [note.note writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }
        [self updateNotesWithBlock:^VOChangeDescribingDictionary *(VOChangeDescribingDictionary *currentNotes) {
          VOMutableChangeDescribingDictionary *mutableNotes = [currentNotes mutableCopy];
          [notesDictionary enumerateKeysAndObjectsUsingBlock:^(NSString *noteTitle, PVNote *savedNote, BOOL *stop) {
            PVNote *existingNote = mutableNotes[noteTitle];
            if ([savedNote.note isEqualToString:existingNote.note]) {
              PVMutableNote *mutableNote = [existingNote mutableCopy];
              mutableNote.dirty = NO;
              mutableNotes[noteTitle] = mutableNote;
            }
          }];
          return [mutableNotes copy];
        }];
      }];
}

- (void)updateNote:(PVNote *)noteToUpdate
{
  if (!noteToUpdate) {
    return;
  }
  [self updateNotesWithBlock:^VOChangeDescribingDictionary *(VOChangeDescribingDictionary *currentNotes) {
    VOMutableChangeDescribingDictionary *mutableCopy = [currentNotes mutableCopy];
    mutableCopy[noteToUpdate.title] = noteToUpdate;
    return [mutableCopy copy];
  }];
}

#pragma mark - VOPipelineSource

- (VOPipelineState)pipelineState
{
  return [_listeners pipelineState];
}

- (void)startPipeline
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSArray *notesFromDisk = [self _notesFromDisk];
    [self updateNotesWithBlock:^VOChangeDescribingDictionary *(VOChangeDescribingDictionary *currentNotes) {
      VOMutableChangeDescribingDictionary *mutableNotes = [currentNotes mutableCopy];
      for (PVNote *note in notesFromDisk) {
        mutableNotes[note.title] = note;
      }
      return [mutableNotes copy];
    }];
  });
}

- (void)stopPipeline
{
  [_listeners stopPipeline];
}

- (id)addPipelineSink:(id<VOPipelineSink>)listener
{
  [_listeners addPipelineSink:listener];
  return _notes;
}

- (void)removePipelineSink:(id<VOPipelineSink>)listener
{
  [_listeners removePipelineSink:listener];
}

- (void)pipelineSinkWantsToStart:(id<VOPipelineSink>)pipelineSink
{
  dispatch_async(_queue, ^{
    [_listeners pipelineSource:self didUpdateToValue:_notes];
  });
}

@end
