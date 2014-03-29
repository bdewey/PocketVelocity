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
  NSHashTable *_listeners;
}

- (instancetype)init
{
  self = [super init];
  if (self != nil) {
    _listeners = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsObjectPointerPersonality capacity:4];
  }
  return self;
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ _listeners = %@", [super description], _listeners];
}

#pragma mark - VOListenable

- (void)addListener:(id<VOListening>)observer
{
  @synchronized(_listeners) {
    [_listeners addObject:observer];
  }
}

- (void)removeListener:(id<VOListening>)observer
{
  @synchronized(_listeners) {
    [_listeners removeObject:observer];
  }
}

#pragma mark - VOListening

- (void)listenableObject:(id<VOListenable>)listenableObject didUpdateToValue:(id)value
{
  NSArray *listenersCopy;
  @synchronized(_listeners) {
    listenersCopy = [_listeners copy];
  }
  for (id<VOListening> listener in listenersCopy) {
    [listener listenableObject:listenableObject didUpdateToValue:value];
  }
}

@end


