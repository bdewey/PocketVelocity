//
//  PVNotesDatabase.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PVAnnouncing.h"

@class PVNote;
@protocol PVNotesDatabaseListening;

@interface PVNotesDatabase : NSObject <PVAnnouncing>

@property (nonatomic, readonly, copy) NSArray *notes;

- (void)addNote:(PVNote *)note;
- (void)removeNote:(PVNote *)note;
- (void)replaceNote:(PVNote *)note withNote:(PVNote *)newNote;

@end


@protocol PVNotesDatabaseListening <NSObject>

- (void)notesDatabaseWillChange:(PVNotesDatabase *)notesDatabase;
- (void)notesDatabaseDidChange:(PVNotesDatabase *)notesDatabase;

@end