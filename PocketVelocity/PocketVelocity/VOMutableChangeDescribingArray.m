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
  [_insertedIndexes addIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  [(NSMutableArray *)_values removeObjectAtIndex:index];
  [_removedIndexes addIndex:index];
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
