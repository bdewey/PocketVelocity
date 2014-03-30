//
//  VOPipeline.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/28/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipeline.h"

#import "VODebugDescribable.h"
#import "VOListenersCollection.h"
#import "VOValueTransforming.h"

@interface VOPipeline () <VODebugDescribable>
@end

@implementation VOPipeline
{
  id<VOListenable> _source;
  NSArray *_stages;
  dispatch_queue_t _queue;
  VOListenersCollection *_listeners;
  id _currentValue;
  BOOL _valid;
}

@synthesize valid = _valid;

- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source stages:(NSArray *)stages queue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _name = [name copy];
    _source = source;
    _stages = [stages copy];
    _queue = queue;
    _listeners = [[VOListenersCollection alloc] initWithCurrentValue:nil];
    _valid = YES;
    
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

- (instancetype)initWithName:(NSString *)name source:(id<VOListenable>)source
{
  return [self initWithName:name source:source stages:nil];
}

- (instancetype)initWithPipeline:(VOPipeline *)pipeline stages:(NSArray *)stages
{
  self = [self initWithName:pipeline->_name source:pipeline stages:stages queue:pipeline->_queue];
  if (self != nil) {
    _chainedPipeline = YES;
  }
  return self;
}

- (void)dealloc
{
  [_source removeListener:self];
}

- (void)invalidate
{
  _valid = NO;
  [_source removeListener:self];
}

#pragma mark - VODebugDescribable

- (void)vo_describeInMutableString:(NSMutableString *)mutableString
{
  BOOL sourceConformsToDescribable = [_source conformsToProtocol:@protocol(VODebugDescribable)];
  if (sourceConformsToDescribable) {
    [(id<VODebugDescribable>)_source vo_describeInMutableString:mutableString];
  }
  [mutableString appendFormat:@"<%@ %p: ", NSStringFromClass([self class]), self];
  if (!_chainedPipeline) {
    [mutableString appendFormat:@"%@ ", _name];
  }
  if (!sourceConformsToDescribable) {
    [mutableString appendFormat:@"%@ ", _source];
  }
  if (_stages) {
    if (_stages.count == 1) {
      [mutableString appendFormat:@"%@ ", _stages[0]];
    } else {
      [mutableString appendFormat:@"%@ ", _stages];
    }
  }
  [mutableString appendFormat:@"\n\tcurrentValue = %@\n>\n", _currentValue];
}

- (NSString *)description
{
  NSMutableString *mutableString = [[NSMutableString alloc] init];
  [self vo_describeInMutableString:mutableString];
  return mutableString;
}

#pragma mark - VOListening

- (void)listenableObject:(id<VOListening>)listenableObject didUpdateToValue:(id)value
{
  VO_RETURN_IF_INVALID();
  dispatch_block_t block = ^{
    _currentValue = value;
    for (id<VOValueTransforming> stage in _stages) {
      _currentValue = [stage transformValue:_currentValue];
    }
    [_listeners listenableObject:self didUpdateToValue:_currentValue];
  };
  if (_chainedPipeline || (_mainQueuePipeline && [NSThread isMainThread])) {
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
