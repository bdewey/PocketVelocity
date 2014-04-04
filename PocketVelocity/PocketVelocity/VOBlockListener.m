//
//  VOBlockListener.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOBlockListener.h"

@implementation VOBlockListener
{
  VOBlockListenerBlock _block;
  BOOL _mainQueueOptimize;
  BOOL _valid;
}

@synthesize valid = _valid;

- (instancetype)initWithSource:(id<VOPipelineSource>)source callbackQueue:(dispatch_queue_t)queue block:(VOBlockListenerBlock)block
{
  self = [super init];
  if (self != nil) {
    _source = source;
    _block = block;
    _queue = queue;
    _mainQueueOptimize = (_queue == dispatch_get_main_queue());
    _valid = YES;
    
    [self pipelineSource:_source didUpdateToValue:[_source addPipelineSink:self]];
  }
  return self;
}

- (instancetype)initWithSource:(id<VOPipelineSource>)source block:(VOBlockListenerBlock)block
{
  return [self initWithSource:source callbackQueue:dispatch_get_main_queue() block:block];
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

#pragma mark - VOPipelineSink

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  VO_RETURN_IF_INVALID();
  if (_mainQueueOptimize && [NSThread isMainThread]) {
    _block(value);
  } else {
    dispatch_async(_queue, ^{
      _block(value);
    });
  }
}

- (void)pipelineSourceDidStop:(id<VOPipelineSource>)pipelineSource
{
  // NOTHING
}

@end

@implementation VOPipelineStage (VOBlockListener)

- (VOBlockListener *)mainQueueBlock:(VOBlockListenerBlock)block
{
  return [[VOBlockListener alloc] initWithSource:self block:block];
}

- (VOBlockListener *)blockListenerOnQueue:(dispatch_queue_t)queue block:(VOBlockListenerBlock)block
{
  return [[VOBlockListener alloc] initWithSource:self callbackQueue:queue block:block];
}

@end