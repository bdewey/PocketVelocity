//  Copyright (c) 2014 Brian Dewey. All rights reserved.

#import <Foundation/Foundation.h>

#import "PVListenable.h"

@class PVArrayChangeDescription;

/**
 When listening to changes to this data source, the change description is class PVArrayChangeDescription.
 */
@interface PVListenableArray : NSObject <PVListenable>

@property (nonatomic, readonly, assign) NSUInteger count;

- (id)objectAtIndex:(NSUInteger)index;
- (id)objectAtIndexedSubscript:(NSUInteger)index;
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)addObject:(id)object;
- (void)removeLastObject;
- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;

@end

