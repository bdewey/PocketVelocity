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
}

- (instancetype)initWithBlock:(VOBlockListenerBlock)block callbackQueue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _block = block;
    _queue = queue;
    _mainQueueOptimize = (_queue == dispatch_get_main_queue());
  }
  return self;
}

- (instancetype)initWithBlock:(VOBlockListenerBlock)block
{
  return [self initWithBlock:block callbackQueue:dispatch_get_main_queue()];
}

#pragma mark - VOListening

- (void)listenableObject:(id<VOListenable>)listenableObject didUpdateToValue:(id)value
{
  if (_mainQueueOptimize && [NSThread isMainThread]) {
    _block(value);
  } else {
    dispatch_async(_queue, ^{
      _block(value);
    });
  }
}

@end
