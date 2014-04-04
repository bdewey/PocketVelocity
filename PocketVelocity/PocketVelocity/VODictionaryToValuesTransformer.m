//
//  VODictionaryToValuesTransformer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/3/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VODictionaryToValuesTransformer.h"

#import "VOArrayChangeDescription.h"
#import "VOTransformingPipelineStage.h"

@implementation VODictionaryToValuesTransformer

- (instancetype)initWithComparator:(NSComparator)comparator
{
  self = [super init];
  if (self != nil) {
    _comparator = comparator;
  }
  return self;
}

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingDictionary *)value
                             previousResult:(VOChangeDescribingArray *)previousResult
{
  NSMutableArray *mutableValues = [value.dictionary.allValues mutableCopy];
  [mutableValues sortUsingComparator:_comparator];
  VOArrayChangeDescription *changeDescription = [VOArrayChangeDescription arrayChangeDescriptionFromOldArray:previousResult.values
                                                                                                updatedArray:mutableValues];
  return [[VOChangeDescribingArray alloc] initWithValues:mutableValues changeDescription:changeDescription];
}

@end

@implementation VOPipelineStage (VODictionaryToValuesTransformer)

- (VOPipelineStage *)pipelineStageWithDictionaryToValuesWithComparator:(NSComparator)comparator
{
  VODictionaryToValuesTransformer *transformer = [[VODictionaryToValuesTransformer alloc] initWithComparator:comparator];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:transformer];
}

@end
