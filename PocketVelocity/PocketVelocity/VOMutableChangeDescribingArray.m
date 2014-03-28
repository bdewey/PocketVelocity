//
//  PVMutableListenableArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/22/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "VOChangeDescribingArray_Internal.h"
#import "VOMutableChangeDescribingArray.h"

@implementation VOMutableChangeDescribingArray
{
  NSMutableIndexSet *_insertedIndexes;
  NSMutableIndexSet *_removedIndexes;
}

- (instancetype)initWithValues:(NSArray *)values changeDescription:(VOArrayChangeDescription *)changeDescription
{
  self = [super initWithValues:values changeDescription:changeDescription];
  if (self != nil) {
    _values = [values mutableCopy];
    _insertedIndexes = [[NSMutableIndexSet alloc] init];
    _removedIndexes = [[NSMutableIndexSet alloc] init];
  }
  return self;
}

- (VOArrayChangeDescription *)changeDescription
{
  return [[VOArrayChangeDescription alloc] initWithIndexesToRemoveFromOldValues:_removedIndexes indexesToAddFromUpdatedValues:_insertedIndexes];
}

#pragma mark - NSMutableArray

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
  [(NSMutableArray *)_values insertObject:[object copy] atIndex:index];
  [_insertedIndexes shiftIndexesStartingAtIndex:index by:1];
  [_insertedIndexes addIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  [(NSMutableArray *)_values removeObjectAtIndex:index];
  if ([_insertedIndexes containsIndex:index]) {
    [_insertedIndexes removeIndex:index];
  } else {
    // _removedIndexes uses the **old** index space.
    // We need to convert `index` (in the current space) to the old space by logically undoing
    // all of the insertions and removals we have seen so far.
    // Our index sets describe doing all removals before insertions, so undo them in the reverse order.
    NSUInteger indexesInsertedBeforeIndex = [_insertedIndexes countOfIndexesInRange:NSMakeRange(0, index)];
    index -= indexesInsertedBeforeIndex;
    NSUInteger indexesRemovedBeforeIndex = [_removedIndexes countOfIndexesInRange:NSMakeRange(0, index+1)];
    index += indexesRemovedBeforeIndex;
    [_removedIndexes addIndex:index];
  }
}

- (void)addObject:(id)object
{
  [self insertObject:object atIndex:self.count];
}

- (void)removeLastObject
{
  [self removeObjectAtIndex:self.count-1];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
  id oldValue = _values[index];
  if ([oldValue isEqual:object]) {
    return;
  }
  [(NSMutableArray *)_values replaceObjectAtIndex:index withObject:object];
  [_insertedIndexes addIndex:index];
  [_removedIndexes addIndex:index];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
{
  [self replaceObjectAtIndex:index withObject:object];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return [[VOChangeDescribingArray alloc] initWithValues:_values changeDescription:self.changeDescription];
}

@end
