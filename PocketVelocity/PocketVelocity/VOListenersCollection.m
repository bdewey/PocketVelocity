//
//  PVListenersCollection.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOListenersCollection.h"

@implementation VOListenersCollection
{
  id _currentValue;
  NSHashTable *_listeners;
}

- (instancetype)initWithCurrentValue:(id)currentValue
{
  self = [super init];
  if (self != nil) {
    _currentValue = currentValue;
    _listeners = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality capacity:4];
  }
  return self;
}

- (instancetype)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not designated initializer" userInfo:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ _listeners = %@", [super description], _listeners];
}

#pragma mark - VOListenable

- (id)addListener:(id<VOListening>)observer
{
  [_listeners addObject:observer];
  return _currentValue;
}

- (void)removeListener:(id<VOListening>)observer
{
  [_listeners removeObject:observer];
}

#pragma mark - VOListening

- (void)listenableObject:(id<VOListenable>)listenableObject didUpdateToValue:(id)value
{
  _currentValue = value;
  for (id<VOListening> listener in _listeners) {
    [listener listenableObject:listenableObject didUpdateToValue:value];
  }
}

@end


