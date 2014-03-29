//
//  VOPipeline.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipeline.h"

#import "VOListenersCollection.h"
#import "VOValueTransforming.h"

@implementation VOPipeline
{
  id<VOListenable> _source;
  NSArray *_stages;
  dispatch_queue_t _queue;
  VOListenersCollection *_listeners;
  id _curentValue;
}

- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source stages:(NSArray *)stages queue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _name = [name copy];
    _source = source;
    _stages = [stages copy];
    _queue = queue;
    _listeners = [[VOListenersCollection alloc] initWithCurrentValue:nil];
    
    _mainQueuePipeline = (_queue == dispatch_get_main_queue());
    
    [self listenableObject:source didUpdateToValue:[source addListener:self]];
  }
  return self;
}

- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source stages:(NSArray *)stages
{
  dispatch_queue_t serialQueue = dispatch_queue_create([name cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
  dispatch_set_target_queue(serialQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
  return [self initWithName:name source:source stages:stages queue:serialQueue];
}

- (void)dealloc
{
  [_source removeListener:self];
}

#pragma mark - VOListening

- (void)listenableObject:(id<VOListening>)listenableObject didUpdateToValue:(id)value
{
  dispatch_block_t block = ^{
    _curentValue = value;
    for (id<VOValueTransforming> stage in _stages) {
      _curentValue = [stage transformValue:_curentValue];
    }
    [_listeners listenableObject:self didUpdateToValue:_curentValue];
  };
  if (_mainQueuePipeline && [NSThread isMainThread]) {
    block();
  } else {
    dispatch_async(_queue, block);
  }
}

#pragma mark - VOListenable

- (id)addListener:(id<VOListening>)listener
{
  return [_listeners addListener:listener];
}

- (void)removeListener:(id<VOListening>)listener
{
  [_listeners removeListener:listener];
}

@end
