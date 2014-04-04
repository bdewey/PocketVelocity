//
//  VODictionaryMapTransformer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/3/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VODictionaryMapTransformer.h"

#import "VOChangeDescribingDictionary.h"
#import "VODictionaryChangeDescription.h"
#import "VOMutableChangeDescribingDictionary.h"
#import "VOTransformingPipelineStage.h"

@implementation VODictionaryMapTransformer

- (instancetype)initWithValueTransformer:(id<VOValueTransforming>)transformer
{
  self = [super init];
  if (self != nil) {
    _transformer = transformer;
  }
  return self;
}

#pragma mark - VOValueTransforming

- (VOChangeDescribingDictionary *)transformValue:(VOChangeDescribingDictionary *)value
                                  previousResult:(VOChangeDescribingDictionary *)previousResult
{
  VOMutableChangeDescribingDictionary *mutableResults;
  VODictionaryChangeDescription *changeDescription;
  if (previousResult == nil) {
    mutableResults = [[VOMutableChangeDescribingDictionary alloc] init];
    changeDescription = [[VODictionaryChangeDescription alloc] initWithInsertedOrUpdatedKeys:[NSSet setWithArray:value.dictionary.allKeys]
                                                                                 removedKeys:[NSSet set]];
  } else {
    mutableResults = [previousResult mutableCopy];
    changeDescription = value.changeDescription;
  }
  for (id<NSCopying> key in changeDescription.removedKeys) {
    [mutableResults removeObjectForKey:key];
  }
  for (id<NSCopying> key in changeDescription.insertedOrUpdatedKeys) {
    id originalValue = value[key];
    id priorTransformedValue = mutableResults[key];
    id transformedValue = [_transformer transformValue:originalValue previousResult:priorTransformedValue];
    mutableResults[key] = transformedValue;
  }
  return [mutableResults copy];
}

@end

@implementation VOPipelineStage (VODictionaryMapTransformer)

- (VOPipelineStage *)pipelineWithDictionaryMappingBlock:(VOValueTransformingBlock)block
{
  VOBlockTransformer *blockTransformer = [[VOBlockTransformer alloc] initWithBlock:block];
  VODictionaryMapTransformer *transformer = [[VODictionaryMapTransformer alloc] initWithValueTransformer:blockTransformer];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:transformer];
}

- (VOPipelineStage *)pipelineWithDictionaryMappingTransformer:(id<VOValueTransforming>)transformer
{
  VODictionaryMapTransformer *dictionaryTransformer = [[VODictionaryMapTransformer alloc] initWithValueTransformer:transformer];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:dictionaryTransformer];
}

@end
