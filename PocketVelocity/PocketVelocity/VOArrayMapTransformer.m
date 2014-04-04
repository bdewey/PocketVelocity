//
//  PVMappedArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/23/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayChangeDescription.h"
#import "VOArrayMapTransformer.h"
#import "VOChangeDescribingArray_Internal.h"
#import "VOMutableChangeDescribingArray.h"

@interface VOArrayMapTransformer()

@end

@implementation VOArrayMapTransformer

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer
{
  self = [super init];
  if (self != nil) {
    _transformer = transformer;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ transformer = %@",
          [super description],
          _transformer];
}

#pragma mark - VOValueTransforming

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value
                             previousResult:(VOChangeDescribingArray *)previousResult
{
  VOChangeDescribingArray *immutableResults;
  if (previousResult == nil) {
    VOMutableChangeDescribingArray *updatedValues = [[VOMutableChangeDescribingArray alloc] init];
    for (int i = 0; i < value.count; i++) {
      id updatedValue = [_transformer transformValue:value[i] previousResult:nil];
      [updatedValues addObject:updatedValue];
    }
    immutableResults = [updatedValues copy];
  } else {
    immutableResults = [self _transformValue:value asDeltaFromOldValue:previousResult];
  }
  return immutableResults;
}

- (VOChangeDescribingArray *)_transformValue:(VOChangeDescribingArray *)value
                         asDeltaFromOldValue:(VOChangeDescribingArray *)oldValue
{
  VOArrayChangeDescription *changeDescription = value.changeDescription;
  VOMutableChangeDescribingArray *updatedMappedValues = (oldValue != nil) ? [oldValue mutableCopy] : [[VOMutableChangeDescribingArray alloc] init];
  [changeDescription.indexesToRemoveFromOldValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [updatedMappedValues removeObjectAtIndex:idx];
  }];
  [changeDescription.indexesToAddFromUpdatedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    id transformedValue = [_transformer transformValue:value[idx] previousResult:nil];
    [updatedMappedValues insertObject:transformedValue atIndex:idx];
  }];
  VOChangeDescribingArray *immutableCopy = [updatedMappedValues copy];
  return immutableCopy;
}

@end

@implementation VOPipelineStage (VOArrayMapTransformer)

- (VOPipelineStage *)pipelineWithArrayMappingBlock:(VOValueTransformingBlock)block
{
  VOBlockTransformer *itemTransformer = [[VOBlockTransformer alloc] initWithBlock:block];
  VOArrayMapTransformer *mapTransformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:itemTransformer];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:mapTransformer];
}

- (VOPipelineStage *)pipelineWithArrayMappingTransformer:(id<VOValueTransforming>)transformer
{
  VOArrayMapTransformer *mapTransformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:transformer];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:mapTransformer];
}

@end

