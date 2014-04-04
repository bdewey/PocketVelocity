//
//  PVListenersCollection.m
//  PocketVelocity
//
//  Created by Brian Dewey on 3/21/14.
//  Copyright (c) 2014 Brian Dewey. All rights reserved.
//

#import "NSObject+VOUtilities.h"
#import "VOPipelineStage.h"

@implementation VOPipelineStage
{
  id _currentValue;
  NSHashTable *_listeners;
  VOPipelineState _pipelineState;
  BOOL _valid;
}

@synthesize pipelineState = _pipelineState;
@synthesize valid = _valid;

- (instancetype)initWithSource:(id<VOPipelineSource>)source
{
  self = [super init];
  if (self != nil) {
    _source = source;
    [_source addPipelineSink:self];
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

- (void)invalidate
{
  _valid = NO;
  [_source removePipelineSink:self];
}

- (NSString *)description
{
  return [self vo_descriptionWithProperties:@{@"currentValue": NSNULL_IF_NIL(_currentValue)}];
}

#pragma mark - VOPipelineSource

- (NSString *)pipelineDescription
{
  NSString *sourceDescription = [_source pipelineDescription];
  if (sourceDescription != nil) {
    return [NSString stringWithFormat:@"%@\n\n  >>>>>>>> NEXT STAGE >>>>>>>> \n\n%@", sourceDescription, [self description]];
  } else {
    return [self description];
  }
}

- (id)currentValue
{
  @synchronized(self) {
    return _currentValue;
  }
}

- (void)startPipeline
{
  BOOL needsStarting = NO;
  @synchronized(self) {
    if (_pipelineState == VOPipelineStateInitialized) {
      _pipelineState = VOPipelinePendingStart;
      needsStarting = YES;
    }
  }
  if (needsStarting) {
    [_source pipelineSinkWantsToStart:self];
  }
}

- (void)stopPipeline
{
  BOOL needsStopping = NO;
  NSHashTable *listenersCopy = nil;
  @synchronized(self) {
    if (_pipelineState != VOPipelineStateStopped) {
      needsStopping = YES;
      _pipelineState = VOPipelineStateStopped;
      listenersCopy = [_listeners copy];
    }
  }
  if (needsStopping) {
    for (id<VOPipelineSink> sink in listenersCopy) {
      [sink pipelineSourceDidStop:self];
    }
  }
}

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

- (void)pipelineSinkWantsToStart:(id<VOPipelineSink>)pipelineSink
{
  if (_pipelineState == VOPipelineStateStarted) {
    [pipelineSink pipelineSource:self didUpdateToValue:self.currentValue];
  } else {
    [self startPipeline];
  }
}

#pragma mark - VOPipelineSink

- (void)pipelineSource:(id<VOPipelineSource>)listenableObject didUpdateToValue:(id)value
{
  VO_RETURN_IF_INVALID();
  NSHashTable *listenersCopy;
  VOPipelineState pipelineStateCopy;
  @synchronized(self) {
    if (_pipelineState < VOPipelineStateStarted) {
      _pipelineState = VOPipelineStateStarted;
    }
    _currentValue = value;
    pipelineStateCopy = _pipelineState;
    listenersCopy = [_listeners copy];
  }
  if (pipelineStateCopy == VOPipelineStateStopped) {
    return;
  }
  for (id<VOPipelineSink> listener in listenersCopy) {
    [listener pipelineSource:listenableObject didUpdateToValue:value];
  }
}

- (void)pipelineSourceDidStop:(id<VOPipelineSource>)pipelineSource
{
  [self stopPipeline];
}

@end


