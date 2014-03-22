//
//  PVNotesDatabase.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVAnnouncer.h"
#import "PVNotesDatabase.h"

@implementation PVNotesDatabase
{
  PVAnnouncer *_announcer;
  NSMutableArray *_notes;
}

- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    _announcer = [[PVAnnouncer alloc] init];
    _notes = [[NSMutableArray alloc] init];
  }
  return self;
}

#pragma mark - Public API

- (void)addNote:(PVNote *)note
{
  [self _announceWillChange];
  [_notes addObject:note];
  [self _announceDidChange];
}

- (void)removeNote:(PVNote *)note
{
  [self _announceWillChange];
  [_notes removeObject:note];
  [self _announceDidChange];
}

- (void)replaceNote:(PVNote *)note withNote:(PVNote *)newNote
{
  [self _announceWillChange];
  NSUInteger index = [_notes indexOfObject:note];
  [_notes replaceObjectAtIndex:index withObject:newNote];
  [self _announceDidChange];
}

#pragma mark - Properties

- (NSArray *)notes
{
  return [_notes copy];
}

#pragma mark - PVAnnouncing

- (void)addListener:(id)listener
{
  [_announcer addListener:listener];
}

- (void)removeListener:(id)listener
{
  [_announcer removeListener:listener];
}

- (void)_announceWillChange
{
  [_announcer enumerateListenersWithBlock:^(id<PVNotesDatabaseListening> listener) {
    [listener notesDatabaseWillChange:self];
  }];
}

- (void)_announceDidChange
{
  [_announcer enumerateListenersWithBlock:^(id<PVNotesDatabaseListening> listener) {
    [listener notesDatabaseDidChange:self];
  }];
}

@end
