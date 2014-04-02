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
  BOOL _valid;
}

@synthesize valid = _valid;

- (instancetype)initWithSource:(id<VOPipelineSource>)source
{
  self = [super init];
  if (self != nil) {
    _source = source;
    _currentValue = [_source addPipelineSink:self];
    _listeners = [[NSHashTable alloc] initWithOptions:(NSPointerFunctionsObjectPointerPersonality | NSHashTableWeakMemory)
                                             capacity:4];
    _valid = YES;
  }
  return self;
}

- (instancetype)init
{
  return [self initWithSource:nil];
}

- (void)dealloc
{
  [_source removePipelineSink:self];
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

- (void)invalidate
{
  _valid = NO;
  [_source removePipelineSink:self];
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
  VO_RETURN_IF_INVALID();
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


