//
//  PVListenersCollection.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVListenersCollection.h"

@implementation PVListenersCollection
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

- (void)addListener:(id<PVListening>)observer
{
  @synchronized(_listeners) {
    [_listeners addObject:observer];
  }
}

- (void)removeListener:(id<PVListening>)observer
{
  @synchronized(_listeners) {
    [_listeners removeObject:observer];
  }
}

#pragma mark - PVListening

- (void)listenableObject:(id)object didChangeWithDescription:(id)changeDescription
{
  NSArray *listenersCopy;
  @synchronized(_listeners) {
    listenersCopy = [_listeners copy];
  }
  for (id<PVListening> listener in listenersCopy) {
    [listener listenableObject:object didChangeWithDescription:changeDescription];
  }
}

@end


