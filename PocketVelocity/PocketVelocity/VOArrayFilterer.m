//
//  VOArrayFilterer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOArrayFilterer.h"
#import "VOMutableChangeDescribingArray.h"

@implementation VOArrayFilterer
{
  VOArrayFilterValidationBlock _validationBlock;
}

- (instancetype)initWithTransformer:(id<VOValueTransforming>)transformer
           expectsPipelineSemantics:(BOOL)expectsPipelineSemantics
                    validationBlock:(VOArrayFilterValidationBlock)validationBlock
{
  self = [super init];
  if (self != nil) {
    _transformer = transformer;
    _expectsPipelineSemantics = expectsPipelineSemantics;
    _validationBlock = validationBlock;
  }
  return self;
}

- (instancetype)initWithTransformer:(id<VOValueTransforming>)transformer expectsPipelineSemantics:(BOOL)expectsPipelineSemantics
{
  return [self initWithTransformer:transformer expectsPipelineSemantics:expectsPipelineSemantics validationBlock:nil];
}

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)values previousResult:(VOChangeDescribingArray *)previousResult
{
  VOMutableChangeDescribingArray *mutableResults = [[VOMutableChangeDescribingArray alloc] init];

  for (id value in values) {
    id outcome = [_transformer transformValue:value previousResult:nil];
    if (outcome != nil) {
      [mutableResults addObject:value];
    }
  }
  VOChangeDescribingArray *immutableResults = [mutableResults copy];
  if (_validationBlock) {
    NSAssert(_validationBlock(immutableResults), @"Validation test");
  }
  return immutableResults;
}

@end

@implementation VOPipelineStage (VOArrayFilterer)

- (VOPipelineStage *)pipelineWithArrayFilteringBlock:(VOValueTransformingBlock)block
{
  VOBlockTransformer *blockTransformer = [[VOBlockTransformer alloc] initWithBlock:block];
  VOArrayFilterer *arrayFilterer = [[VOArrayFilterer alloc] initWithTransformer:blockTransformer expectsPipelineSemantics:YES];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:arrayFilterer];
}

- (VOPipelineStage *)pipelineWithArrayFilteringTransformer:(id<VOValueTransforming>)transformer
{
  VOArrayFilterer *arrayFilterer = [[VOArrayFilterer alloc] initWithTransformer:transformer expectsPipelineSemantics:YES];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:arrayFilterer];
}

@end
