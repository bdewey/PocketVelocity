//
//  VOPipeline.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOTransformingPipelineStage.h"

#import "VODebugDescribable.h"
#import "VOPipelineStage_Subclassing.h"
#import "VOValueTransforming.h"

@interface VOTransformingPipelineStage () <VODebugDescribable>
@end

@implementation VOTransformingPipelineStage
{
  dispatch_queue_t _queue;
  id _currentValue;
}

@synthesize currentValue = _currentValue;

- (instancetype)initWithSource:(id<VOPipelineSource>)source transformer:(id<VOValueTransforming>)transformer
{
  self = [super initWithSource:source];
  if (self != nil) {
    _transformer = transformer;
    [self pipelineSource:source didUpdateToValue:[source addPipelineSink:self]];
  }
  return self;
}

#pragma mark - VODebugDescribable

- (void)vo_describeInMutableString:(NSMutableString *)mutableString
{
  id source = self.source;
  BOOL sourceConformsToDescribable = [source conformsToProtocol:@protocol(VODebugDescribable)];
  if (sourceConformsToDescribable) {
    [(id<VODebugDescribable>)source vo_describeInMutableString:mutableString];
  }
  [mutableString appendFormat:@"<%@ %p: ", NSStringFromClass([self class]), self];
  if (!sourceConformsToDescribable) {
    [mutableString appendFormat:@"%@ ", source];
  }
  [mutableString appendFormat:@"%@ ", _transformer];
  [mutableString appendFormat:@"\n\tcurrentValue = %@\n>\n", _currentValue];
}

- (NSString *)description
{
  NSMutableString *mutableString = [[NSMutableString alloc] init];
  [self vo_describeInMutableString:mutableString];
  return mutableString;
}

#pragma mark - Subclass override

- (id)transformValue:(id)value shouldContinueToSinks:(BOOL *)shouldContinueToSinks
{
  *shouldContinueToSinks = YES;
  if (_transformer) {
    return [_transformer transformValue:value];
  } else {
    return value;
  }
}

@end
