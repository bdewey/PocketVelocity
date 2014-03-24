//
//  PVArrayChangeDescription.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "BDLongestCommonSubsequence.h"
#import "PVArrayChangeDescription.h"

@implementation PVArrayChangeDescription

- (instancetype)initWithOldValues:(NSArray *)oldValues
                    updatedValues:(NSArray *)newValues
     indexesToRemoveFromOldValues:(NSIndexSet *)indexesToRemoveFromOldValues
    indexesToAddFromUpdatedValues:(NSIndexSet *)indexesToAddFromUpdatedValues
{
  self = [super init];
  if (self != nil) {
    _oldValues = [oldValues copy];
    _updatedValues = [newValues copy];
    _indexesToRemoveFromOldValues = [indexesToRemoveFromOldValues copy];
    _indexesToAddFromUpdatedValues = [indexesToAddFromUpdatedValues copy];
  }
  return self;
}

+ (PVArrayChangeDescription *)arrayChangeDescriptionByDiffingOldValues:(NSArray *)oldValues newValues:(NSArray *)newValues
{
  BDLongestCommonSubsequence *subsequence = [BDLongestCommonSubsequence subsequenceWithFirstArray:oldValues andSecondArray:newValues];
  NSMutableIndexSet *oldIndexes = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, oldValues.count)];
  NSMutableIndexSet *newIndexes = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, newValues.count)];
  [oldIndexes removeIndexes:subsequence.firstArraySubsequenceIndexes];
  [newIndexes removeIndexes:subsequence.secondArraySubsequenceIndexes];
  return [[PVArrayChangeDescription alloc] initWithOldValues:oldValues
                                               updatedValues:newValues
                                indexesToRemoveFromOldValues:oldIndexes
                               indexesToAddFromUpdatedValues:newIndexes];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ oldValues = %@; updatedValues = %@; indexesToRemoveFromOldValues = %@; indexesToAddFromUpdatedValues = %@",
          [super description],
          _oldValues,
          _updatedValues,
          _indexesToRemoveFromOldValues,
          _indexesToAddFromUpdatedValues];
}

@end

@implementation PVArrayChangeDescription (NSIndexPath)

- (NSArray *)indexPathsToRemoveFromOldValuesUsingSection:(NSUInteger)section
{
  return [self _transformIndexSet:_indexesToRemoveFromOldValues toIndexPathArrayUsingSection:section];
}

- (NSArray *)indexPathsToAddFromNewValuesUsingSection:(NSUInteger)section
{
  return [self _transformIndexSet:_indexesToAddFromUpdatedValues toIndexPathArrayUsingSection:section];
}

- (NSArray *)_transformIndexSet:(NSIndexSet *)indexSet toIndexPathArrayUsingSection:(NSUInteger)section
{
  NSMutableArray *results = [[NSMutableArray alloc] initWithCapacity:indexSet.count];
  [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [results addObject:[NSIndexPath indexPathForRow:idx inSection:section]];
  }];
  return results;
}

@end
