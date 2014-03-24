//
//  PVListenersCollection.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVListenersCollection.h"

@interface PVListenerQueuePair ()

- (instancetype)initWithListener:(id)listener callbackQueue:(dispatch_queue_t)queue;

@end

@implementation PVListenersCollection
{
  NSMutableArray *_listeners;
}

- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    _listeners = [[NSMutableArray alloc] init];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ _listeners = %@", [super description], _listeners];
}

- (void)addListener:(id<PVListening>)observer callbackQueue:(dispatch_queue_t)queue
{
  PVListenerQueuePair *pair = [[PVListenerQueuePair alloc] initWithListener:observer callbackQueue:queue];
  @synchronized(_listeners) {
    [_listeners addObject:pair];
  }
}

- (void)addListener:(id<PVListening>)observer
{
  [self addListener:observer callbackQueue:nil];
}

- (void)removeListener:(id<PVListening>)observer
{
  @synchronized(_listeners) {
    for (PVListenerQueuePair *pair in _listeners) {
      if ([pair isEqual:observer]) {
        [_listeners removeObject:pair];
        break;
      }
    }
  }
}

- (void)enumerateListenersWithBlock:(PVListenerEnumerationBlock)block
{
  NSArray *listenersCopy;
  @synchronized(_listeners) {
    listenersCopy = [_listeners copy];
  }
  for (PVListenerQueuePair *pair in listenersCopy) {
    block(pair);
  }
}

@end


@implementation PVListenerQueuePair

- (instancetype)initWithListener:(id)listener callbackQueue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _listener = listener;
    _callbackQueue = queue;
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ listener = <%@ %p> queue = %@", [super description], [_listener class], _listener, _callbackQueue];
}

- (BOOL)isEqual:(id)object
{
  if (![object isKindOfClass:[self class]]) {
    return NO;
  }
  PVListenerQueuePair *otherPair = (PVListenerQueuePair *)object;
  return [_listener isEqual:otherPair->_listener];
}

- (NSUInteger)hash
{
  return [_listener hash];
}

@end