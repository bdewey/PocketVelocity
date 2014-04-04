//
//  VODictionaryFilterer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/2/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VODictionaryChangeDescription.h"
#import "VODictionaryFilterer.h"
#import "VOChangeDescribingDictionary.h"
#import "VOMutableChangeDescribingDictionary.h"
#import "VOTransformingPipelineStage.h"

@implementation VODictionaryFilterer

- (instancetype)initWithFilterBlock:(VODictionaryFiltererBlock)filterBlock
{
  self = [super init];
  if (self != nil) {
    _filterBlock = [filterBlock copy];
  }
  return self;
}

- (id)transformValue:(VOChangeDescribingDictionary *)value
      previousResult:(VOChangeDescribingDictionary *)previousResult
{
  if (previousResult != nil) {
    VOMutableChangeDescribingDictionary *mutableResults = [previousResult mutableCopy];
    VODictionaryChangeDescription *changeDescription = value.changeDescription;
    for (id<NSCopying> key in changeDescription.removedKeys) {
      [mutableResults removeObjectForKey:key];
    }
    for (id<NSCopying> key in changeDescription.insertedOrUpdatedKeys) {
      id mapValue = value[key];
      if (_filterBlock(key, mapValue)) {
        [mutableResults setObject:mapValue forKey:key];
      } else {
        [mutableResults removeObjectForKey:key];
      }
    }
    return [mutableResults copy];
  }
  VOMutableChangeDescribingDictionary *mutableResults = [[VOMutableChangeDescribingDictionary alloc] init];
  NSDictionary *dictionary = [value dictionary];
  [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (_filterBlock(key, obj)) {
      [mutableResults setObject:obj forKey:key];
    }
  }];
  return [mutableResults copy];
}

@end

@implementation VOPipelineStage (VODictionaryFilterer)

- (VOPipelineStage *)pipelineByFilteringDictionaryWithBlock:(VODictionaryFiltererBlock)block
{
  VODictionaryFilterer *filterer = [[VODictionaryFilterer alloc] initWithFilterBlock:block];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:filterer];
}

@end
