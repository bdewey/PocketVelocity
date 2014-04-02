//
//  PVAsyncListening.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVAsyncListening.h"
#import "VOListenersCollection.h"

@implementation PVAsyncListening
{
  id _currentValue;
  VOListenersCollection *_listeners;
  BOOL _shouldInvokeSynchronouslyOnMainThread;
}

- (instancetype)initWithListenableObject:(id<VOPipelineSource>)object queue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _source = object;
    _queue = queue;
    _shouldInvokeSynchronouslyOnMainThread = (_queue == dispatch_get_main_queue());
    _currentValue = [_source addListener:self];
    _listeners = [[VOListenersCollection alloc] initWithCurrentValue:_currentValue];
  }
  return self;
}

- (void)dealloc
{
  [_source removeListener:self];
}

#pragma mark - PVListenable

- (id)addListener:(id<VOPipelineSink>)listener
{
  [_listeners addListener:listener];
  return _currentValue;
}

- (void)removeListener:(id<VOPipelineSink>)listener
{
  [_listeners removeListener:listener];
}

#pragma mark - PVListening

- (void)listenableObject:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  // Main queue optimization: If we're supposed to run on the main queue and we're currently on the main thread,
  // invoke synchronously.
  _currentValue = value;
  if (_shouldInvokeSynchronouslyOnMainThread && [NSThread isMainThread]) {
    [_listeners listenableObject:listenableObject didUpdateToValue:value];
  } else {
    dispatch_async(_queue, ^{
      [_listeners listenableObject:listenableObject didUpdateToValue:value];
    });
  }
}

@end

