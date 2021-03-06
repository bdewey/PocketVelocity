//
//  PVSectionedDataSourceTransformer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVSectionedDataSourceTransformer.h"
#import "PVSectionedDataSource.h"

#import "VOChangeDescribingArray.h"
#import "VOTransformingPipelineStage.h"

@implementation PVSectionedDataSourceTransformer
{
  PVSectionedDataSource *_oldValue;
}

- (instancetype)initWithPipelineSemantics:(BOOL)expectsPipelineSemantics
{
  self = [super init];
  if (self != nil) {
    _expectsPipelineSemantics = expectsPipelineSemantics;
  }
  return self;
}

- (PVSectionedDataSource *)transformValue:(VOChangeDescribingArray *)value previousResult:(id)previousResult
{
  PVSectionedDataSource *updatedValue;
  if (value == nil) {
    updatedValue = nil;
  } else if (_oldValue == nil) {
    updatedValue = [[PVSectionedDataSource alloc] initWithSections:@[value]];
  } else {
    PVMutableSectionedDataSource *mutableCopy = [_oldValue mutableCopy];
    mutableCopy[0] = value;
    updatedValue = [mutableCopy copy];
  }
  if (_expectsPipelineSemantics) {
    _oldValue = updatedValue;
  }
  return updatedValue;
}

@end

@implementation VOPipelineStage (PVSectionedDataSourceTransformer)

- (VOPipelineStage *)pipelineTransformingToSectionedDataSource
{
  PVSectionedDataSourceTransformer *transformer = [[PVSectionedDataSourceTransformer alloc] initWithPipelineSemantics:YES];
  return [[VOTransformingPipelineStage alloc] initWithSource:self transformer:transformer];
}

@end