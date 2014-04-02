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
  id<VOPipelineSource> _source;
  dispatch_queue_t _queue;
  id _currentValue;
  BOOL _valid;
}

@synthesize currentValue = _currentValue;
@synthesize valid = _valid;

- (instancetype)initWithSource:(id<VOPipelineSource>)source transformer:(id<VOValueTransforming>)transformer
{
  self = [super initWithCurrentValue:nil];
  if (self != nil) {
    _source = source;
    _transformer = transformer;
    [self pipelineSource:source didUpdateToValue:[source addPipelineSink:self]];
  }
  return self;
}

- (void)dealloc
{
  [_source removePipelineSink:self];
}

- (void)invalidate
{
  _valid = NO;
  [_source removePipelineSink:self];
}

#pragma mark - VODebugDescribable

- (void)vo_describeInMutableString:(NSMutableString *)mutableString
{
  BOOL sourceConformsToDescribable = [_source conformsToProtocol:@protocol(VODebugDescribable)];
  if (sourceConformsToDescribable) {
    [(id<VODebugDescribable>)_source vo_describeInMutableString:mutableString];
  }
  [mutableString appendFormat:@"<%@ %p: ", NSStringFromClass([self class]), self];
  if (!sourceConformsToDescribable) {
    [mutableString appendFormat:@"%@ ", _source];
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
