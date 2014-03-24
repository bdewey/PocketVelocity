//
//  PVMappedArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "PVMappedArray.h"
#import "PVListenableArray_Internal.h"

@interface PVMappedArray() <PVListening>

@end

@implementation PVMappedArray
{
  PVMappedArrayMappingBlock _mappingBlock;
}

- (instancetype)initWithSourceArray:(PVListenableArray *)source mappingBlock:(PVMappedArrayMappingBlock)block
{
  NSArray *sourceValues = source.values;
  NSMutableArray *mappedValues = [[NSMutableArray alloc] initWithCapacity:sourceValues.count];
  for (id object in sourceValues) {
    id mappedObject = block(object);
    [mappedValues addObject:mappedObject];
  }
  self = [super initWithValues:mappedValues];
  if (self != nil) {
    _source = [source copy];
    _mappingBlock = block;
    [_source addListener:self];
  }
  return self;
}

- (void)dealloc
{
  [_source removeListener:self];
}

#pragma mark - PVListening

- (void)listenableObject:(PVListenableArray *)object didChangeWithDescription:(PVArrayChangeDescription *)changeDescription
{
  NSArray *originalMappedValues = self.values;
  NSMutableArray *updatedMappedValues = [originalMappedValues mutableCopy];
  NSArray *updatedValues = changeDescription.updatedValues;
  NSMutableIndexSet *mappedIndexesToRemove = [changeDescription.indexesToRemoveFromOldValues mutableCopy];
  NSMutableIndexSet *mappedIndexesToAdd    = [changeDescription.indexesToAddFromUpdatedValues mutableCopy];
  [updatedMappedValues removeObjectsAtIndexes:changeDescription.indexesToRemoveFromOldValues];
  [changeDescription.indexesToAddFromUpdatedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    id originalObject = updatedValues[idx];
    // TODO: Memoize this calculation.
    id mappedObject = _mappingBlock(originalObject);
    [updatedMappedValues insertObject:mappedObject atIndex:idx];
    if ([changeDescription.indexesToRemoveFromOldValues containsIndex:idx] && [originalMappedValues[idx] isEqual:mappedObject]) {
      // Optimization: For each index that is both in the "inserted" and "deleted" set... if the value is the same
      // before and after, it's not a change.
      [mappedIndexesToRemove removeIndex:idx];
      [mappedIndexesToAdd removeIndex:idx];
    }
  }];
  
  if (mappedIndexesToAdd.count || mappedIndexesToRemove.count) {
    PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:originalMappedValues
                                                                            updatedValues:updatedMappedValues
                                                             indexesToRemoveFromOldValues:mappedIndexesToRemove
                                                            indexesToAddFromUpdatedValues:mappedIndexesToAdd];
    [self _updateValues:updatedMappedValues changeDescription:delta];
  }
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not implemented" userInfo:nil];
}

@end

@implementation PVListenableArray (PVMappedArray)

- (PVMappedArray *)mappedArrayWithMappingBlock:(PVMappedArrayMappingBlock)mappingBlock
{
  return [[PVMappedArray alloc] initWithSourceArray:self mappingBlock:mappingBlock];
}

@end