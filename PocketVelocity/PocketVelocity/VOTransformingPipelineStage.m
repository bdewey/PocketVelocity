//
//  VOPipeline.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSObject+VOUtilities.h"
#import "VOTransformingPipelineStage.h"
#import "VOValueTransforming.h"

@implementation VOTransformingPipelineStage

- (instancetype)initWithSource:(id<VOPipelineSource>)source transformer:(id<VOValueTransforming>)transformer
{
  self = [super initWithSource:source];
  if (self != nil) {
    _transformer = transformer;
  }
  return self;
}

#pragma mark - VODebugDescribable

- (NSString *)vo_descriptionWithProperties:(NSDictionary *)properties
{
  NSMutableDictionary *mergedProperties = [properties mutableCopy];
  [mergedProperties addEntriesFromDictionary:@{@"transformer": NSStringFromClass([_transformer class])}];
  return [super vo_descriptionWithProperties:mergedProperties];
}

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(id)value
{
  value = [_transformer transformValue:value previousResult:self.currentValue];
  [super pipelineSource:pipelineSource didUpdateToValue:value];
}

@end
