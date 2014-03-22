//
//  PVAnnouncer.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/15/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "PVAnnouncer.h"

@implementation PVAnnouncer
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

- (void)addListener:(id)listener
{
  @synchronized(_listeners) {
    [_listeners addObject:listener];
  }
}

- (void)removeListener:(id)listener
{
  @synchronized(_listeners) {
    [_listeners removeObject:listener];
  }
}

- (void)enumerateListenersWithBlock:(PVAnnouncerEnumerationBlock)block
{
  NSArray *listenersCopy;
  @synchronized(_listeners) {
    listenersCopy = [_listeners copy];
  }
  for (id listener in listenersCopy) {
    block(listener);
  }
}

@end
