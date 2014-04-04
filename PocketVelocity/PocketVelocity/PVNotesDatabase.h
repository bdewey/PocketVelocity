//
//  PVNotesDatabase.h
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VOPipelining.h"

@class VOBlockListener;
@class VOChangeDescribingDictionary;
@class VOMutableChangeDescribingDictionary;

typedef VOChangeDescribingDictionary * (^PVNotesDatabaseUpdatingBlock)(VOChangeDescribingDictionary *currentNotes);

@interface PVNotesDatabase : NSObject <VOPipelineSource>

@property (nonatomic, readonly, copy) NSURL *directory;
@property (nonatomic, readonly, copy) VOChangeDescribingDictionary *notes;

- (instancetype)initWithDirectory:(NSURL *)directory;
- (void)updateNotesWithBlock:(PVNotesDatabaseUpdatingBlock)block;
- (void)removeNoteWithTitle:(NSString *)noteTitle;
- (void)updateNote:(PVNote *)note;
- (VOBlockListener *)autoSaveListener;

@end
