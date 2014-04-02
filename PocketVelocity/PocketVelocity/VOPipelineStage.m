//
//  PVListenersCollection.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "VOPipelineStage.h"
#import "VOPipelineStage_Subclassing.h"

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
  return [NSString stringWithFormat:@"%@ currentValue = %@", [super description], _currentValue];
}

- (id)currentValue
{
  @synchronized(self) {
    return _currentValue;
  }
}

#pragma mark - Override point for subclasses

- (id)transformValue:(id)value shouldContinueToSinks:(BOOL *)shouldPassToSinks 
{
  *shouldPassToSinks = YES;
  return value;
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
  BOOL shouldContinueToSinks = NO;
  value = [self transformValue:value shouldContinueToSinks:&shouldContinueToSinks];
  @synchronized(self) {
    _currentValue = value;
    if (shouldContinueToSinks) {
      listenersCopy = [_listeners copy];
    }
  }
  if (shouldContinueToSinks) {
    for (id<VOPipelineSink> listener in listenersCopy) {
      [listener pipelineSource:listenableObject didUpdateToValue:value];
    }
  }
}

@end


