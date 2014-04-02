//
//  PVAsyncListening.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVAsyncListening.h"
#import "VOPipelineStage.h"

@implementation PVAsyncListening
{
  id _currentValue;
  VOPipelineStage *_listeners;
  BOOL _shouldInvokeSynchronouslyOnMainThread;
}

@synthesize currentValue = _currentValue;

- (instancetype)initWithListenableObject:(id<VOPipelineSource>)object queue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _source = object;
    _queue = queue;
    _shouldInvokeSynchronouslyOnMainThread = (_queue == dispatch_get_main_queue());
    _currentValue = [_source addPipelineSink:self];
    _listeners = [[VOPipelineStage alloc] initWithCurrentValue:_currentValue];
  }
  return self;
}

- (void)dealloc
{
  [_source removePipelineSink:self];
}

#pragma mark - PVListenable

- (id)addPipelineSink:(id<VOPipelineSink>)listener
{
  [_listeners addPipelineSink:listener];
  return _currentValue;
}

- (void)removePipelineSink:(id<VOPipelineSink>)listener
{
  [_listeners removePipelineSink:listener];
}

#pragma mark - PVListening

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  // Main queue optimization: If we're supposed to run on the main queue and we're currently on the main thread,
  // invoke synchronously.
  _currentValue = value;
  if (_shouldInvokeSynchronouslyOnMainThread && [NSThread isMainThread]) {
    [_listeners pipelineSource:listenableObject didUpdateToValue:value];
  } else {
    dispatch_async(_queue, ^{
      [_listeners pipelineSource:listenableObject didUpdateToValue:value];
    });
  }
}

@end

