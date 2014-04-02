//
//  PVListenersCollection.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipelineStage.h"

@implementation VOPipelineStage
{
  id _currentValue;
  NSHashTable *_listeners;
}

- (instancetype)initWithCurrentValue:(id)currentValue
{
  self = [super init];
  if (self != nil) {
    _currentValue = currentValue;
    _listeners = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsObjectPointerPersonality | NSHashTableWeakMemory)
                                             capacity:4];
  }
  return self;
}

- (instancetype)init
{
  @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not designated initializer" userInfo:nil];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ currentValue = %@, listeners = %@", [super description], _currentValue, _listeners];
}

- (id)currentValue
{
  @synchronized(self) {
    return _currentValue;
  }
}

#pragma mark - VOListenable

- (id)addPipelineSink:(id<VOPipelineSink>)observer
{
  @synchronized(self) {
    [_listeners addObject:observer];
    return _currentValue;
  }
}

- (void)removePipelineSink:(id<VOPipelineSink>)observer
{
  @synchronized(self) {
    [_listeners removeObject:observer];
  }
}

#pragma mark - VOListening

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  NSHashTable *listenersCopy;
  @synchronized(self) {
    _currentValue = value;
    listenersCopy = [_listeners copy];
  }
  for (id<VOPipelineSink> listener in listenersCopy) {
    [listener pipelineSource:listenableObject didUpdateToValue:value];
  }
}

@end


