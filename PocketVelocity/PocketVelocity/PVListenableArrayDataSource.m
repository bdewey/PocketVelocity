//
//  PVObservableArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "PVListenableArrayDataSource.h"
#import "PVListenersCollection.h"

@implementation PVListenableArrayDataSource
{
  NSArray *_values;
  PVListenersCollection *_listeners;
}

- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    _values = [[NSArray alloc] init];
    _listeners = [[PVListenersCollection alloc] init];
  }
  return self;
}

#pragma mark - PVListenable

- (void)addListener:(id<PVListening>)observer callbackQueue:(dispatch_queue_t)queue
{
  [_listeners addListener:observer callbackQueue:queue];
}

- (void)addListener:(id<PVListening>)observer
{
  [_listeners addListener:observer];
}

- (void)removeListener:(id<PVListening>)observer
{
  [_listeners removeListener:observer];
}

#pragma mark - NSArray

- (id)objectAtIndex:(NSUInteger)index
{
  return [_values objectAtIndex:index];
}

- (NSUInteger)count
{
  return _values.count;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
  return _values[index];
}

#pragma mark - NSMutableArray

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
  NSMutableArray *updatedValues = [_values mutableCopy];
  [updatedValues insertObject:object atIndex:index];
  PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:_values
                                                                          updatedValues:updatedValues
                                                           indexesToRemoveFromOldValues:[NSIndexSet indexSet]
                                                          indexesToAddFromUpdatedValues:[NSIndexSet indexSetWithIndex:index]];
  [self _updateValues:updatedValues changeDescription:delta];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
  NSMutableArray *updatedValues = [_values mutableCopy];
  [updatedValues removeObjectAtIndex:index];
  PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:_values
                                                                          updatedValues:updatedValues
                                                           indexesToRemoveFromOldValues:[NSIndexSet indexSetWithIndex:index]
                                                          indexesToAddFromUpdatedValues:[NSIndexSet indexSet]];
  [self _updateValues:updatedValues changeDescription:delta];
}

- (void)addObject:(id)object
{
  [self insertObject:object atIndex:self.count];
}

- (void)removeLastObject
{
  [self removeObjectAtIndex:self.count-1];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
  NSMutableArray *updatedValues = [_values mutableCopy];
  [updatedValues replaceObjectAtIndex:index withObject:object];
  PVArrayChangeDescription *delta = [[PVArrayChangeDescription alloc] initWithOldValues:_values
                                                                          updatedValues:updatedValues
                                                           indexesToRemoveFromOldValues:[NSIndexSet indexSetWithIndex:index]
                                                          indexesToAddFromUpdatedValues:[NSIndexSet indexSetWithIndex:index]];
  [self _updateValues:updatedValues changeDescription:delta];
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
{
  [self replaceObjectAtIndex:index withObject:object];
}

- (void)_updateValues:(NSArray *)updatedValues changeDescription:(PVArrayChangeDescription *)changeDescription
{
  _values = [updatedValues copy];
  [_listeners enumerateListenersWithBlock:^(PVListenerQueuePair *listenerQueuePair) {
    dispatch_block_t callbackBlock = ^{
      [listenerQueuePair.listener listenableObject:self didChangeWithDescription:changeDescription];
    };
    if (listenerQueuePair.callbackQueue) {
      dispatch_async(listenerQueuePair.callbackQueue, callbackBlock);
    } else {
      callbackBlock();
    }
  }];
}

@end
