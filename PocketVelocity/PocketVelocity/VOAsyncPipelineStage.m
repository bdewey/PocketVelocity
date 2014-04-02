//
//  VOAsyncPipelineStage.m
//  PocketVelocity
//
//  Created by Brian Dewey on 4/1/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOAsyncPipelineStage.h"

@implementation VOAsyncPipelineStage
{
  BOOL _shouldInvokeSynchronouslyOnMainThread;
}

- (instancetype)initWithSource:(id<VOPipelineSource>)source queue:(dispatch_queue_t)queue
{
  self = [super initWithCurrentValue:nil];
  if (self != nil) {
    _source = source;
    _queue = queue;
    _shouldInvokeSynchronouslyOnMainThread = (_queue == dispatch_get_main_queue());
    [_source addPipelineSink:self];
  }
  return self;
}

- (void)dealloc
{
  [_source removePipelineSink:self];
}

#pragma mark - VOPipelineSink

- (void)pipelineSource:(id<VOPipelineSource>)pipelineSource didUpdateToValue:(id)value
{
  if (_shouldInvokeSynchronouslyOnMainThread && [NSThread isMainThread]) {
    [super pipelineSource:pipelineSource didUpdateToValue:value];
  } else {
    dispatch_async(_queue, ^{
      [super pipelineSource:pipelineSource didUpdateToValue:value];
    });
  }
}
@end
