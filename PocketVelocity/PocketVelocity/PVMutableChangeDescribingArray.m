//
//  PVMutableListenableArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/22/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "VOChangeDescribingArray_Internal.h"
#import "PVMutableChangeDescribingArray.h"

@implementation PVMutableChangeDescribingArray
{
  
}

#pragma mark - NSMutableArray

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
  NSArray *oldValues = self.values;
  NSMutableArray *updatedValues = [oldValues mutableCopy];
  [updatedValues insertObject:[object copy] atIndex:index];
  PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:oldValues
                                                                          updatedValues:updatedValues
                                                           indexesToRemoveFromOldValues:[NSIndexSet indexSet]
                                                          indexesToAddFromUpdatedValues:[NSIndexSet indexSetWithIndex:index]];
  [self _updateValues:updatedValues changeDescription:delta];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  NSArray *oldValues = self.values;
  NSMutableArray *updatedValues = [oldValues mutableCopy];
  [updatedValues removeObjectAtIndex:index];
  PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:oldValues
                                                                          updatedValues:updatedValues
                                                           indexesToRemoveFromOldValues:[NSIndexSet indexSetWithIndex:index]
                                                          indexesToAddFromUpdatedValues:[NSIndexSet indexSet]];
  [self _updateValues:updatedValues changeDescription:delta];
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
  NSArray *oldValues = self.values;
  NSMutableArray *updatedValues = [oldValues mutableCopy];
  [updatedValues replaceObjectAtIndex:index withObject:[object copy]];
  PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:oldValues
                                                                          updatedValues:updatedValues
                                                           indexesToRemoveFromOldValues:[NSIndexSet indexSetWithIndex:index]
                                                          indexesToAddFromUpdatedValues:[NSIndexSet indexSetWithIndex:index]];
  [self _updateValues:updatedValues changeDescription:delta];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
{
  [self replaceObjectAtIndex:index withObject:object];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return [[VOChangeDescribingArray alloc] initWithValues:self.values changeDescription:self.changeDescription];
}

@end