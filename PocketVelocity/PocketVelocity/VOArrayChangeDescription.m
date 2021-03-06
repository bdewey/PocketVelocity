//
//  PVArrayChangeDescription.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "BDLongestCommonSubsequence.h"
#import "VOArrayChangeDescription.h"

@implementation VOArrayChangeDescription

- (instancetype)initWithIndexesToRemoveFromOldValues:(NSIndexSet *)indexesToRemoveFromOldValues indexesToAddFromUpdatedValues:(NSIndexSet *)indexesToAddFromUpdatedValues
{
  self = [super init];
  if (self != nil) {
    _indexesToRemoveFromOldValues = [indexesToRemoveFromOldValues copy];
    _indexesToAddFromUpdatedValues = [indexesToAddFromUpdatedValues copy];
  }
  return self;
}

+ (instancetype)arrayChangeDescriptionFromOldArray:(NSArray *)oldArray updatedArray:(NSArray *)updatedArray
{
  BDLongestCommonSubsequence *subsequence = [BDLongestCommonSubsequence subsequenceWithFirstArray:oldArray
                                                                                   andSecondArray:updatedArray];
  NSMutableIndexSet *oldIndexes = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, oldArray.count)];
  NSMutableIndexSet *updatedIndexes = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, updatedArray.count)];
  [oldIndexes removeIndexes:subsequence.firstArraySubsequenceIndexes];
  [updatedIndexes removeIndexes:subsequence.secondArraySubsequenceIndexes];
  return [[[self class] alloc] initWithIndexesToRemoveFromOldValues:oldIndexes
                                      indexesToAddFromUpdatedValues:updatedIndexes];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ indexesToRemoveFromOldValues = %@; indexesToAddFromUpdatedValues = %@",
          [super description],
          _indexesToRemoveFromOldValues,
          _indexesToAddFromUpdatedValues];
}

@end

@implementation VOArrayChangeDescription (NSIndexPath)

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
