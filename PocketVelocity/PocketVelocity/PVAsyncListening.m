//
//  PVAsyncListening.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/24/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVAsyncListening.h"
#import "PVListenersCollection.h"

@implementation PVAsyncListening
{
  PVListenersCollection *_listeners;
}

- (instancetype)initWithListenableObject:(id<PVListenable>)object queue:(dispatch_queue_t)queue
{
  self = [super init];
  if (self != nil) {
    _source = object;
    _queue = queue;
    _listeners = [[PVListenersCollection alloc] init];
    [_source addListener:self];
  }
  return self;
}

- (void)dealloc
{
  [_source removeListener:self];
}

#pragma mark - PVListenable

- (void)addListener:(id<PVListening>)listener
{
  [_listeners addListener:listener];
}

- (void)removeListener:(id<PVListening>)listener
{
  [_listeners removeListener:listener];
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(id)changeDescription
{
  dispatch_async(_queue, ^{
    [_listeners listenableObject:object didChangeWithDescription:changeDescription];
  });
}

@end

@implementation PVListenableArray (PVAsyncListening)

- (PVAsyncListening *)defaultQueueArray
{
  return [[PVAsyncListening alloc] initWithListenableObject:self
                                                      queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

- (PVAsyncListening *)mainQueueArray
{
  return [[PVAsyncListening alloc] initWithListenableObject:self
                                                      queue:dispatch_get_main_queue()];
}

@end