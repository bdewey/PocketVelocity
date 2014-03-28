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

- (instancetype)initWithTransformer:(id<VOValueTransforming>)transformer
           expectsPipelineSemantics:(BOOL)expectsPipelineSemantics
{
  self = [super init];
  if (self != nil) {
    _transformer = transformer;
    _expectsPipelineSemantics = expectsPipelineSemantics;
  }
  return self;
}

- (VOChangeDescribingArray *)transformValue:(VOChangeDescribingArray *)values
{
  VOMutableChangeDescribingArray *mutableResults = [[VOMutableChangeDescribingArray alloc] init];

  for (id value in values) {
    id outcome = [_transformer transformValue:value];
    if (outcome != nil) {
      [mutableResults addObject:value];
    }
  }
  return [mutableResults copy];
}

@end
