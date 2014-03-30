//
//  PVNotesDatabase.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOListenable.h"

@class VOBlockListener;
@class VOChangeDescribingArray;
@class VOMutableChangeDescribingArray;

typedef VOChangeDescribingArray * (^PVNotesDatabaseUpdatingBlock)(VOChangeDescribingArray *currentNotes);

@interface PVNotesDatabase : NSObject <VOListenable>

@property (nonatomic, readonly, copy) NSURL *directory;
@property (nonatomic, readonly, copy) VOChangeDescribingArray *notes;

- (instancetype)initWithDirectory:(NSURL *)directory;
- (void)updateNotesWithBlock:(PVNotesDatabaseUpdatingBlock)block;
- (void)loadNotesFromDisk;
- (void)removeNoteWithTitle:(NSString *)noteTitle;
- (void)updateNote:(PVNote *)note;
- (VOBlockListener *)autoSaveListener;

@end
