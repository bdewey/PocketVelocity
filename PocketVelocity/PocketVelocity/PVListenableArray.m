//
//  PVObservableArray.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/17/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVArrayChangeDescription.h"
#import "PVListenableArray.h"
#import "PVListenableArray_Internal.h"
#import "PVListenersCollection.h"
#import "PVMutableListenableArray.h"

@implementation PVListenableArray
{
  PVListenersCollection *_listeners;
}

- (instancetype)initWithValues:(NSArray *)values
{
  self = [super init];
  if (self != nil) {
    _values = [values copy];
    _listeners = [[PVListenersCollection alloc] init];
  }
  return self;
}

- (instancetype)init
{
  return [self initWithValues:[[NSArray alloc] init]];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ _values = %@; _listeners = %@", [super description], _values, _listeners];
}

#pragma mark - PVListenable

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

- (void)_updateValues:(NSArray *)updatedValues changeDescription:(PVArrayChangeDescription *)changeDescription
{
  _values = [updatedValues copy];
  [_listeners listenableObject:self didChangeWithDescription:changeDescription];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [[PVMutableListenableArray alloc] initWithValues:_values];
}

@end
