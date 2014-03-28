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
  VOChangeDescribingArray *_immutableOriginalValues;
  NSMutableIndexSet *_insertedIndexes;
  NSMutableIndexSet *_removedIndexes;
}

- (instancetype)initWithOriginalValues:(VOChangeDescribingArray *)originalValues
{
  NSArray *originalArray;
  if (originalValues != nil) {
    originalArray = originalValues->_values;
  } else {
    originalArray = [[NSArray alloc] init];
  }
  self = [super initWithValues:originalArray changeDescription:nil];
  if (self != nil) {
    _immutableOriginalValues = [originalValues copy];
    _values = [originalArray mutableCopy];
    _insertedIndexes = [[NSMutableIndexSet alloc] init];
    _removedIndexes = [[NSMutableIndexSet alloc] init];
  }
  return self;
}

- (instancetype)init
{
  return [self initWithOriginalValues:nil];
}

- (id)initWithValues:(NSArray *)values changeDescription:(VOArrayChangeDescription *)changeDescription
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not designated initializer" userInfo:nil];
}

- (VOArrayChangeDescription *)changeDescription
{
  return [[VOArrayChangeDescription alloc] initWithIndexesToRemoveFromOldValues:_removedIndexes indexesToAddFromUpdatedValues:_insertedIndexes];
}

#pragma mark - NSMutableArray

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
  [(NSMutableArray *)_values insertObject:[object copy] atIndex:index];
  
  // Why the -1? The index space mapping doesn't work yet because we haven't yet recorded the insert we just did.
  NSUInteger indexFromOriginalValues = [self _indexInOriginalValuesFromNewIndex:index] - 1;
  
  // Optimization -- check if the item we just inserted is equal to one we earlier removed from this location
  // If it is, record this by pretending the removal didn't happen
  if ([_removedIndexes containsIndex:indexFromOriginalValues]) {
    id originalValue = _immutableOriginalValues[indexFromOriginalValues];
    if ([originalValue isEqual:object]) {
      [_removedIndexes removeIndex:index];
      return;
    }
  }
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
    index = [self _indexInOriginalValuesFromNewIndex:index];
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

#pragma mark - Private

- (NSUInteger)_indexInOriginalValuesFromNewIndex:(NSUInteger)index
{
  NSUInteger indexesInsertedBeforeIndex = [_insertedIndexes countOfIndexesInRange:NSMakeRange(0, index)];
  index -= indexesInsertedBeforeIndex;
  NSUInteger indexesRemovedBeforeIndex = [_removedIndexes countOfIndexesInRange:NSMakeRange(0, index+1)];
  index += indexesRemovedBeforeIndex;
  return index;
}

@end
