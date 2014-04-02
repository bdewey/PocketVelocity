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
{
  VOChangeDescribingArray *_oldArray;
}

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer
                expectsPipelineSemantics:(BOOL)expectsPipelineSemantics
{
  self = [super init];
  if (self != nil) {
    _transformer = transformer;
    _expectsPipelineSemantics = expectsPipelineSemantics;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ pipelining = %@ oldArray = %@ transformer = %@",
          [super description],
          (_expectsPipelineSemantics) ? @"YES" : @"NO",
          _oldArray,
          _transformer];
}

#pragma mark - VOValueTransforming

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)value
{
  VOChangeDescribingArray *immutableResults;
  if (_oldArray == nil) {
    VOMutableChangeDescribingArray *updatedValues = [[VOMutableChangeDescribingArray alloc] init];
    for (int i = 0; i < value.count; i++) {
      id updatedValue = [_transformer transformValue:value[i]];
      [updatedValues addObject:updatedValue];
    }
    immutableResults = [updatedValues copy];
  } else {
    immutableResults = [self _transformValue:value asDeltaFromOldValue:_oldArray];
  }
  if (_expectsPipelineSemantics) {
    _oldArray = immutableResults;
  }
  return immutableResults;
}

- (VOChangeDescribingArray *)_transformValue:(VOChangeDescribingArray *)value asDeltaFromOldValue:(VOChangeDescribingArray *)oldValue
{
  VOArrayChangeDescription *changeDescription = value.changeDescription;
  VOMutableChangeDescribingArray *updatedMappedValues = (oldValue != nil) ? [oldValue mutableCopy] : [[VOMutableChangeDescribingArray alloc] init];
  [changeDescription.indexesToRemoveFromOldValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    [updatedMappedValues removeObjectAtIndex:idx];
  }];
  [changeDescription.indexesToAddFromUpdatedValues enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
    id transformedValue = [_transformer transformValue:value[idx]];
    [updatedMappedValues insertObject:transformedValue atIndex:idx];
  }];
  VOChangeDescribingArray *immutableCopy = [updatedMappedValues copy];
  return immutableCopy;
}

@end

@implementation VOTransformingPipelineStage (VOArrayMapTransformer)

- (VOTransformingPipelineStage *)pipelineWithArrayMappingBlock:(VOValueTransformingBlock)block
{
  VOBlockTransformer *itemTransformer = [[VOBlockTransformer alloc] initWithBlock:block];
  VOArrayMapTransformer *mapTransformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:itemTransformer expectsPipelineSemantics:YES];
  return [[VOTransformingPipelineStage alloc] initWithPipeline:self transformer:mapTransformer];
}

- (VOTransformingPipelineStage *)pipelineWithArrayMappingTransformer:(id<VOValueTransforming>)transformer
{
  VOArrayMapTransformer *mapTransformer = [[VOArrayMapTransformer alloc] initWithValueTransformer:transformer expectsPipelineSemantics:YES];
  return [[VOTransformingPipelineStage alloc] initWithPipeline:self transformer:mapTransformer];
}

@end

