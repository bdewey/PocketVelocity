//
//  PVNotesDatabase.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PVMutableChangeDescribingArray;

typedef VOChangeDescribingArray * (^PVNotesDatabaseUpdatingBlock)(VOChangeDescribingArray *currentNotes);

@interface PVNotesDatabase : NSObject <PVListenable>

@property (nonatomic, readonly, copy) NSURL *directory;
@property (nonatomic, readonly, copy) VOChangeDescribingArray *notes;

- (instancetype)initWithDirectory:(NSURL *)directory;
- (void)updateNotesWithBlock:(PVNotesDatabaseUpdatingBlock)block;

@end
